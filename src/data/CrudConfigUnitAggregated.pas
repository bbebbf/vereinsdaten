unit CrudConfigUnitAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoUnitAggregated, SqlConnection, CrudConfigUnit, CrudConfig, DtoUnit,
  RecordActions;

type
  TCrudConfigUnitAggregated = class(TInterfacedBase, IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfigUnit: ICrudConfig<TDtoUnit, UInt32>;
    fUnitRecordActions: TRecordActions<TDtoUnit, UInt32>;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoUnit;
    function IsEntryValidForList(const aEntry: TDtoUnit): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoUnitAggregated): Boolean;
    procedure DestroyEntry(var aEntry: TDtoUnitAggregated);
    procedure DestroyListEntry(var aEntry: TDtoUnit);
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoUnitAggregated): Boolean;
    function CreateEntry: TDtoUnitAggregated;
    function CloneEntry(const aEntry: TDtoUnitAggregated): TDtoUnitAggregated;
    function IsEntryUndefined(const aEntry: TDtoUnitAggregated): Boolean;
    function SaveEntry(var aEntry: TDtoUnitAggregated): Boolean;
    function DeleteEntry(const aId: UInt32): Boolean;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList;

{ TCrudConfigUnitAggregated }

constructor TCrudConfigUnitAggregated.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfigUnit := TCrudConfigUnit.Create;
  fUnitRecordActions := TRecordActions<TDtoUnit, UInt32>.Create(fConnection, fCrudConfigUnit);
end;

destructor TCrudConfigUnitAggregated.Destroy;
begin
  fUnitRecordActions.Free;
  inherited;
end;

function TCrudConfigUnitAggregated.CloneEntry(const aEntry: TDtoUnitAggregated): TDtoUnitAggregated;
begin
  Result := TDtoUnitAggregated.Create(aEntry.&Unit);
end;

function TCrudConfigUnitAggregated.CreateEntry: TDtoUnitAggregated;
begin
  Result := TDtoUnitAggregated.Create(default(TDtoUnit));
end;

function TCrudConfigUnitAggregated.DeleteEntry(const aId: UInt32): Boolean;
begin
  Result := False;
end;

procedure TCrudConfigUnitAggregated.DestroyEntry(var aEntry: TDtoUnitAggregated);
begin
  FreeAndNil(aEntry);
end;

procedure TCrudConfigUnitAggregated.DestroyListEntry(var aEntry: TDtoUnit);
begin
  aEntry := default(TDtoUnit);
end;

function TCrudConfigUnitAggregated.GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoUnit;
begin
  Result := default(TDtoUnit);
  fCrudConfigUnit.GetRecordFromSqlResult(aSqlResult, Result);
end;

function TCrudConfigUnitAggregated.GetListSqlResult: ISqlResult;
begin
  var lSelectList: ISelectList<TDtoUnit>;
  if not Supports(fCrudConfigUnit, ISelectList<TDtoUnit>, lSelectList) then
    raise ENotImplemented.Create('fCrudConfigUnit must implement ISelectList<TDtoUnit>.');
  Result := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
end;

function TCrudConfigUnitAggregated.IsEntryUndefined(const aEntry: TDtoUnitAggregated): Boolean;
begin
  Result := not Assigned(aEntry);
end;

function TCrudConfigUnitAggregated.IsEntryValidForList(const aEntry: TDtoUnit): Boolean;
begin
  Result := True;
end;

function TCrudConfigUnitAggregated.IsEntryValidForSaving(const aEntry: TDtoUnitAggregated): Boolean;
begin
  Result := True;
end;

function TCrudConfigUnitAggregated.SaveEntry(var aEntry: TDtoUnitAggregated): Boolean;
begin
  Result := True;
  var lUnit := aEntry.&Unit;
  if fUnitRecordActions.SaveRecord(lUnit) = TRecordActionsSaveResponse.Created then
  begin
    aEntry.Id := lUnit.Id;
  end;
end;

function TCrudConfigUnitAggregated.TryLoadEntry(const aId: UInt32; out aEntry: TDtoUnitAggregated): Boolean;
begin
  var lUnit := default(TDtoUnit);
  Result := fUnitRecordActions.LoadRecord(aId, lUnit);
  if Result then
  begin
    aEntry := TDtoUnitAggregated.Create(lUnit);
  end;
end;

end.
