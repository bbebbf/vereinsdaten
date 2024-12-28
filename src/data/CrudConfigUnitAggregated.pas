unit CrudConfigUnitAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoUnitAggregated, SqlConnection, CrudConfigUnit, CrudConfig, DtoUnit,
  RecordActions, Vdm.Types;

type
  TCrudConfigUnitAggregated = class(TInterfacedBase, IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfigUnit: ICrudConfig<TDtoUnit, UInt32>;
    fUnitRecordActions: TRecordActions<TDtoUnit, UInt32>;
    fMemberSelectQuery: ISqlPreparedQuery;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoUnit;
    function IsEntryValidForList(const aEntry: TDtoUnit; const aListFilter: TUnitFilter): Boolean;
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

function TCrudConfigUnitAggregated.IsEntryValidForList(const aEntry: TDtoUnit; const aListFilter: TUnitFilter): Boolean;
begin
  Result := aEntry.Active or aListFilter.ShowInactiveUnits;
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
  if not Result then
    Exit;

  aEntry := TDtoUnitAggregated.Create(lUnit);
  if not Assigned(fMemberSelectQuery) then
  begin
    fMemberSelectQuery := fConnection.CreatePreparedQuery(
        'SELECT m.mb_active, m.mb_active_since, m.mb_active_until' +
        ',p.person_id, p.person_vorname, p.person_praeposition, p.person_nachname, p.person_active, r.role_name' +
        ' FROM `member` AS m' +
        ' INNER JOIN `person` AS p ON p.person_id = m.person_id' +
        ' LEFT JOIN `role` AS r ON r.role_id = m.role_id' +
        ' WHERE m.unit_id = :UnitId' +
        ' ORDER BY m.mb_active DESC, IFNULL(r.role_sorting, 10000), m.mb_active_since DESC' +
        ' ,p.person_active DESC, p.person_nachname, p.person_vorname'
      );
  end;
  fMemberSelectQuery.ParamByName('UnitId').Value := lUnit.Id;
  var lSqlResult := fMemberSelectQuery.Open;
  while lSqlResult.Next do
  begin
    var lMemberRec := default(TDtoUnitAggregatedPersonMemberOf);
    lMemberRec.MemberActive := lSqlResult.FieldByName('mb_active').AsBoolean;
    lMemberRec.MemberActiveSince := lSqlResult.FieldByName('mb_active_since').AsDateTime;
    lMemberRec.MemberActiveUntil := lSqlResult.FieldByName('mb_active_until').AsDateTime;
    lMemberRec.PersonNameId.Id := lSqlResult.FieldByName('person_id').AsLargeInt;
    lMemberRec.PersonNameId.Vorname := lSqlResult.FieldByName('person_vorname').AsString;
    lMemberRec.PersonNameId.Praeposition := lSqlResult.FieldByName('person_praeposition').AsString;
    lMemberRec.PersonNameId.Nachname := lSqlResult.FieldByName('person_nachname').AsString;
    lMemberRec.RoleName := lSqlResult.FieldByName('role_name').AsString;
    aEntry.MemberOfList.Add(lMemberRec);
  end;
end;

end.
