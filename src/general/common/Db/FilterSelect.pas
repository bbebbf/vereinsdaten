unit FilterSelect;

interface

uses System.Classes, SqlConnection, SelectListFilter, ListEnumerator, ProgressIndicatorIntf, Transaction;

type
  TFilterSelectItemMatchesFilter<T, F> = procedure(Sender: TObject; const aItem: T; const aFilter: F; var aItemMatches: Boolean) of object;

  TFilterSelectTransactionEventState = (StartTransaction, EndTransactionSuccessful, EndTransactionException);
  TFilterSelectTransactionEvent = procedure(Sender: TObject; const aState: TFilterSelectTransactionEventState;
    const aTransaction: ITransaction) of object;

  TFilterSelect<T; FSelect, FLoop: record> = class
  strict private
    fConnection: ISqlConnection;
    fConfig: ISelectListFilter<T, FSelect>;
    fEnumerator: IListEnumerator<T>;
    fProgressIndicator: IProgressIndicator;
    fProgressText: string;
    fSqlSelect: ISqlPreparedQuery;
    fFilterSelect: FSelect;
    fFilterLoop: FLoop;
    fInFilterUpdate: Integer;
    fOnItemMatchesFilter: TFilterSelectItemMatchesFilter<T, FLoop>;
    fItemCount: Integer;
    fUseTransaction: Boolean;
    fOnTransaction: TFilterSelectTransactionEvent;
    fCurrentListEnumTransaction: ITransaction;
    procedure SetFilterSelect(const aValue: FSelect);
    procedure SetFilterLoop(const aValue: FLoop);
  strict protected
    procedure ApplyFilter;
    procedure FilterChanged; virtual;
    procedure ListEnumBegin; virtual;
    procedure ListEnumProcessItem(const aItem: T; const aSqlResult: ISqlResult); virtual;
    procedure ListEnumEnd; virtual;
    function ItemMatchesFilter(const aItem: T; const aFilter: FLoop): Boolean;
    property CurrentListEnumTransaction: ITransaction read fCurrentListEnumTransaction;
  public
    constructor Create(const aConnection: ISqlConnection; const aConfig: ISelectListFilter<T, FSelect>);
    destructor Destroy; override;
    procedure BeginUpdateFilter;
    procedure EndUpdateFilter;
    property FilterSelect: FSelect read fFilterSelect write SetFilterSelect;
    property FilterLoop: FLoop read fFilterLoop write SetFilterLoop;
    property Enumerator: IListEnumerator<T> read fEnumerator write fEnumerator;
    property ProgressIndicator: IProgressIndicator read fProgressIndicator write fProgressIndicator;
    property ProgressText: string read fProgressText write fProgressText;
    property OnItemMatchesFilter: TFilterSelectItemMatchesFilter<T, FLoop> read fOnItemMatchesFilter write fOnItemMatchesFilter;
    property UseTransaction: Boolean read fUseTransaction write fUseTransaction;
    property OnTransaction: TFilterSelectTransactionEvent read fOnTransaction write fOnTransaction;
  end;

implementation

uses System.SysUtils;

{ TFilterSelect<T, FSelect, FLoop> }

constructor TFilterSelect<T, FSelect, FLoop>.Create(const aConnection: ISqlConnection;
  const aConfig: ISelectListFilter<T, FSelect>);
begin
  inherited Create;
  fConnection := aConnection;
  fConfig := aConfig;
end;

destructor TFilterSelect<T, FSelect, FLoop>.Destroy;
begin
  fConfig := nil;
  fConnection := nil;
  inherited;
end;

procedure TFilterSelect<T, FSelect, FLoop>.ApplyFilter;
begin
  if not Assigned(fSqlSelect) then
  begin
    fSqlSelect := fConnection.CreatePreparedQuery(fConfig.GetSelectListSQL);
  end;
  fConfig.SetSelectListSQLParameter(fFilterSelect, fSqlSelect);
  var lExceptionOccurred := False;
  fCurrentListEnumTransaction := nil;
  if fUseTransaction then
    fCurrentListEnumTransaction := fConnection.StartTransaction;
  if Assigned(fOnTransaction) then
    fOnTransaction(Self, TFilterSelectTransactionEventState.StartTransaction, fCurrentListEnumTransaction);
  try
    try
      ListEnumBegin;
      var lSqlResult := fSqlSelect.Open(fCurrentListEnumTransaction);
      while lSqlResult.Next do
      begin
        var lRecord := default(T);
        fConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
        if ItemMatchesFilter(lRecord, fFilterLoop) then
          ListEnumProcessItem(lRecord, lSqlResult);
      end;
    except
      on Ex: Exception do
      begin
        lExceptionOccurred := True;
        if Assigned(fCurrentListEnumTransaction) and fCurrentListEnumTransaction.Active then
          fCurrentListEnumTransaction.Rollback;
        raise;
      end;
    end;
  finally
    ListEnumEnd;
    if Assigned(fOnTransaction) then
    begin
      if lExceptionOccurred then
        fOnTransaction(Self, TFilterSelectTransactionEventState.EndTransactionException, fCurrentListEnumTransaction)
      else
        fOnTransaction(Self, TFilterSelectTransactionEventState.EndTransactionSuccessful, fCurrentListEnumTransaction);
    end;
    if Assigned(fCurrentListEnumTransaction) and fCurrentListEnumTransaction.Active then
      fCurrentListEnumTransaction.Commit;
    fCurrentListEnumTransaction := nil;
  end;
end;

procedure TFilterSelect<T, FSelect, FLoop>.BeginUpdateFilter;
begin
  fInFilterUpdate := AtomicIncrement(fInFilterUpdate);
end;

procedure TFilterSelect<T, FSelect, FLoop>.EndUpdateFilter;
begin
  var lMoreThanZero := fInFilterUpdate > 0;
  fInFilterUpdate := AtomicDecrement(fInFilterUpdate);
  if lMoreThanZero and (fInFilterUpdate <= 0) then
    FilterChanged;
end;

procedure TFilterSelect<T, FSelect, FLoop>.SetFilterLoop(const aValue: FLoop);
begin
  if CompareMem(@fFilterLoop, @aValue, SizeOf(FLoop)) then
    Exit;

  fFilterLoop := aValue;
  if fInFilterUpdate = 0 then
    FilterChanged;
end;

procedure TFilterSelect<T, FSelect, FLoop>.SetFilterSelect(const aValue: FSelect);
begin
  if CompareMem(@fFilterSelect, @aValue, SizeOf(FSelect)) then
    Exit;

  fFilterSelect := aValue;
  if fInFilterUpdate = 0 then
    FilterChanged;
end;

procedure TFilterSelect<T, FSelect, FLoop>.FilterChanged;
begin

end;

procedure TFilterSelect<T, FSelect, FLoop>.ListEnumBegin;
begin
  if Assigned(fProgressIndicator) then
    fProgressIndicator.ProgressBegin(-1, fProgressText);
  fItemCount := 0;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumBegin;
end;

procedure TFilterSelect<T, FSelect, FLoop>.ListEnumProcessItem(const aItem: T; const aSqlResult: ISqlResult);
begin
  Inc(fItemCount);
  if Assigned(fProgressIndicator) then
    fProgressIndicator.ProgressStep(fItemCount);
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumProcessItem(aItem);
end;

function TFilterSelect<T, FSelect, FLoop>.ItemMatchesFilter(const aItem: T; const aFilter: FLoop): Boolean;
begin
  Result := True;
  if Assigned(fOnItemMatchesFilter) then
    fOnItemMatchesFilter(Self, aItem, aFilter, Result);
end;

procedure TFilterSelect<T, FSelect, FLoop>.ListEnumEnd;
begin
  if Assigned(fProgressIndicator) then
    fProgressIndicator.ProgressEnd;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumEnd;
end;

end.
