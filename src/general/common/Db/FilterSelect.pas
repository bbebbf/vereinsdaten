unit FilterSelect;

interface

uses SqlConnection, SelectListFilter, ListEnumerator, ProgressObserver;

type
  TFilterSelectItemMatchesFilter<T, F> = procedure(Sender: TObject; const aItem: T; const aFilter: F; var aItemMatches: Boolean) of object;

  TFilterSelect<T; FSelect, FLoop: record> = class
  strict private
    fConnection: ISqlConnection;
    fConfig: ISelectListFilter<T, FSelect>;
    fEnumerator: IListEnumerator<T>;
    fProgressObserver: IProgressObserver;
    fProgressText: string;
    fSqlSelect: ISqlPreparedQuery;
    fFilterSelect: FSelect;
    fFilterLoop: FLoop;
    fInFilterUpdate: Integer;
    fOnItemMatchesFilter: TFilterSelectItemMatchesFilter<T, FLoop>;
    fItemCount: Integer;
    procedure SetFilterSelect(const aValue: FSelect);
    procedure SetFilterLoop(const aValue: FLoop);
  strict protected
    procedure ApplyFilter;
    procedure FilterChanged; virtual;
    procedure ListEnumBegin; virtual;
    procedure ListEnumProcessItem(const aItem: T); virtual;
    procedure ListEnumEnd; virtual;
    function ItemMatchesFilter(const aItem: T; const aFilter: FLoop): Boolean;
  public
    constructor Create(const aConnection: ISqlConnection; const aConfig: ISelectListFilter<T, FSelect>);
    procedure BeginUpdateFilter;
    procedure EndUpdateFilter;
    property FilterSelect: FSelect read fFilterSelect write SetFilterSelect;
    property FilterLoop: FLoop read fFilterLoop write SetFilterLoop;
    property Enumerator: IListEnumerator<T> read fEnumerator write fEnumerator;
    property ProgressObserver: IProgressObserver read fProgressObserver write fProgressObserver;
    property ProgressText: string read fProgressText write fProgressText;
    property OnItemMatchesFilter: TFilterSelectItemMatchesFilter<T, FLoop> read fOnItemMatchesFilter write fOnItemMatchesFilter;
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

procedure TFilterSelect<T, FSelect, FLoop>.ApplyFilter;
begin
  if not Assigned(fSqlSelect) then
  begin
    fSqlSelect := fConnection.CreatePreparedQuery(fConfig.GetSelectListSQL);
  end;
  fConfig.SetSelectListSQLParameter(fFilterSelect, fSqlSelect);
  ListEnumBegin;
  try
    var lSqlResult := fSqlSelect.Open;
    while lSqlResult.Next do
    begin
      var lRecord := default(T);
      fConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      if ItemMatchesFilter(lRecord, fFilterLoop) then
        ListEnumProcessItem(lRecord);
    end;
  finally
    ListEnumEnd;
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
  if fInFilterUpdate <= 0 then
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
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressBegin(-1, False, fProgressText);
  fItemCount := 0;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumBegin;
end;

procedure TFilterSelect<T, FSelect, FLoop>.ListEnumProcessItem(const aItem: T);
begin
  Inc(fItemCount);
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressStep(fItemCount);
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
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressEnd;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumEnd;
end;

end.
