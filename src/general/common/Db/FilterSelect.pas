unit FilterSelect;

interface

uses SqlConnection, SelectListFilter, ListEnumerator, ProgressObserver;

type
  TFilterSelectItemIsValid<T, F> = procedure(Sender: TObject; const aItem: T; const aFilter: F; var aIsVald: Boolean) of object;

  TFilterSelect<T; F: record> = class
  strict private
    fConnection: ISqlConnection;
    fConfig: ISelectListFilter<T, F>;
    fEnumerator: IListEnumerator<T>;
    fProgressObserver: IProgressObserver;
    fProgressText: string;
    fSqlSelect: ISqlPreparedQuery;
    fFilter: F;
    fOnItemIsValid: TFilterSelectItemIsValid<T, F>;
    fItemCount: Integer;
    procedure SetFilter(const aValue: F);
  strict protected
    procedure ApplyFilter;
    procedure FilterChanged; virtual;
    procedure ListEnumBegin; virtual;
    procedure ListEnumProcessItem(const aItem: T); virtual;
    procedure ListEnumEnd; virtual;
    function ListItemIsValid(const aItem: T; const aFilter: F): Boolean;
  public
    constructor Create(const aConnection: ISqlConnection; const aConfig: ISelectListFilter<T, F>);
    property Filter: F read fFilter write SetFilter;
    property Enumerator: IListEnumerator<T> read fEnumerator write fEnumerator;
    property ProgressObserver: IProgressObserver read fProgressObserver write fProgressObserver;
    property ProgressText: string read fProgressText write fProgressText;
    property OnItemIsValid: TFilterSelectItemIsValid<T, F> read fOnItemIsValid write fOnItemIsValid;
  end;

implementation

{ TFilterSelect<T, F> }

constructor TFilterSelect<T, F>.Create(const aConnection: ISqlConnection;
  const aConfig: ISelectListFilter<T, F>);
begin
  inherited Create;
  fConnection := aConnection;
  fConfig := aConfig;
end;

procedure TFilterSelect<T, F>.ApplyFilter;
begin
  if not Assigned(fSqlSelect) then
  begin
    fSqlSelect := fConnection.CreatePreparedQuery(fConfig.GetSelectListSQL);
  end;
  fConfig.SetSelectListSQLParameter(fFilter, fSqlSelect);
  ListEnumBegin;
  try
    var lSqlResult := fSqlSelect.Open;
    while lSqlResult.Next do
    begin
      var lRecord := default(T);
      fConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      if ListItemIsValid(lRecord, fFilter) then
        ListEnumProcessItem(lRecord);
    end;
  finally
    ListEnumEnd;
  end;
end;

procedure TFilterSelect<T, F>.SetFilter(const aValue: F);
begin
  if fFilter = aValue then
    Exit;

  fFilter := aValue;
  FilterChanged;
end;

procedure TFilterSelect<T, F>.FilterChanged;
begin

end;

procedure TFilterSelect<T, F>.ListEnumBegin;
begin
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressBegin(-1, False, fProgressText);
  fItemCount := 0;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumBegin;
end;

procedure TFilterSelect<T, F>.ListEnumProcessItem(const aItem: T);
begin
  Inc(fItemCount);
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressStep(fItemCount);
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumProcessItem(aItem);
end;

function TFilterSelect<T, F>.ListItemIsValid(const aItem: T; const aFilter: F): Boolean;
begin
  Result := True;
  if Assigned(fOnItemIsValid) then
    fOnItemIsValid(Self, aItem, aFilter, Result);
end;

procedure TFilterSelect<T, F>.ListEnumEnd;
begin
  if Assigned(fProgressObserver) then
    fProgressObserver.ProgressEnd;
  if Assigned(fEnumerator) then
    fEnumerator.ListEnumEnd;
end;

end.
