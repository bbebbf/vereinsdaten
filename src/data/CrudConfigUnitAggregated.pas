unit CrudConfigUnitAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoUnitAggregated, SqlConnection, CrudConfigUnit, CrudConfig, DtoUnit,
  RecordActionsVersioning, Vdm.Types, Vdm.Versioning.Types, VersionInfoEntryConfig, CrudCommands,
  MemberOfConfigIntf, MemberOfBusinessIntf, MemberOfUI;

type
  TCrudConfigUnitAggregated = class(TInterfacedBase,
    IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>,
    IVersionInfoEntryConfig<TDtoUnitAggregated>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfigUnit: ICrudConfig<TDtoUnit, UInt32>;
    fVersionInfoConfig: IVersionInfoConfig<TDtoUnit, UInt32>;
    fUnitRecordActions: TRecordActionsVersioning<TDtoUnit, UInt32>;
    fMemberSelectQuery: ISqlPreparedQuery;
    fMemberOfConfig: IMemberOfConfigIntf;
    fMemberOfBusiness: IMemberOfBusinessIntf;
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
    function SaveEntry(var aEntry: TDtoUnitAggregated): TCrudSaveResult;
    function DeleteEntry(const aId: UInt32): Boolean;

    function GetVersionInfoEntry(const aEntry: TDtoUnitAggregated; out aVersionInfoEntry: TVersionInfoEntry): Boolean;
    procedure AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TDtoUnitAggregated);
  public
    constructor Create(const aConnection: ISqlConnection; const aMemberOfUI: IMemberOfUI);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList, Vdm.Globals, MemberOfBusiness, CrudMemberConfigMasterUnit;

type
  TVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<TDtoUnit, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TDtoUnit): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;

{ TCrudConfigUnitAggregated }

constructor TCrudConfigUnitAggregated.Create(const aConnection: ISqlConnection; const aMemberOfUI: IMemberOfUI);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfigUnit := TCrudConfigUnit.Create;
  fVersionInfoConfig := TVersionInfoConfig.Create;
  fUnitRecordActions := TRecordActionsVersioning<TDtoUnit, UInt32>.Create(fConnection, fCrudConfigUnit, fVersionInfoConfig);
  fMemberOfConfig := TCrudMemberConfigMasterUnit.Create(fConnection);
  fMemberOfBusiness := TMemberOfBusiness.Create(fConnection, fMemberOfConfig, nil, aMemberOfUI);
  fMemberOfBusiness.Initialize;
end;

destructor TCrudConfigUnitAggregated.Destroy;
begin
  fMemberOfBusiness := nil;
  fMemberOfConfig := nil;
  fUnitRecordActions.Free;
  inherited;
end;

function TCrudConfigUnitAggregated.CloneEntry(const aEntry: TDtoUnitAggregated): TDtoUnitAggregated;
begin
  Result := TDtoUnitAggregated.Create(aEntry.&Unit);
  for var lEntry in aEntry.MemberOfList do
    Result.MemberOfList.Add(lEntry);
  Result.VersionInfo.Assign(aEntry.VersionInfo);
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

function TCrudConfigUnitAggregated.GetVersionInfoEntry(const aEntry: TDtoUnitAggregated;
  out aVersionInfoEntry: TVersionInfoEntry): Boolean;
begin
  Result := True;
  aVersionInfoEntry := aEntry.VersionInfo;
end;

procedure TCrudConfigUnitAggregated.AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TDtoUnitAggregated);
begin
  aTargetEntry.VersionInfo.Assign(aSourceEntry.VersionInfo);
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

function TCrudConfigUnitAggregated.SaveEntry(var aEntry: TDtoUnitAggregated): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  var lUnit := aEntry.&Unit;
  var lResponse := fUnitRecordActions.SaveRecord(lUnit, aEntry.VersionInfo);
  if lResponse.VersioningState = TRecordActionsVersioningResponseVersioningState.ConflictDetected then
  begin
    Exit(TCrudSaveResult.CreateConflictedRecord(aEntry.VersionInfo));
  end;
  if lResponse.Kind = TRecordActionsVersioningSaveKind.Created then
  begin
    aEntry.Id := lUnit.Id;
  end;
end;

function TCrudConfigUnitAggregated.TryLoadEntry(const aId: UInt32; out aEntry: TDtoUnitAggregated): Boolean;
begin
  var lUnit := default(TDtoUnit);
  var lResponse := fUnitRecordActions.LoadRecord(aId, lUnit);
  Result := lResponse.Succeeded;
  if not Result then
    Exit;

  aEntry := TDtoUnitAggregated.Create(lUnit);
  aEntry.VersionInfo.UpdateVersionInfo(lResponse.EntryVersionInfo);
  if not Assigned(fMemberSelectQuery) then
  begin
    fMemberSelectQuery := fConnection.CreatePreparedQuery(
        'SELECT m.mb_id, m.mb_active, m.mb_active_since, m.mb_active_until' +
        ',p.person_id, p.person_vorname, p.person_praeposition, p.person_nachname, p.person_active, r.role_name' +
        ' FROM `member` AS m' +
        ' INNER JOIN `person` AS p ON p.person_id = m.person_id' +
        ' LEFT JOIN `role` AS r ON r.role_id = m.role_id' +
        ' WHERE m.unit_id = :UnitId' +
        ' ORDER BY m.mb_active DESC, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', m.mb_active_since DESC' +
        ' ,p.person_active DESC, p.person_nachname, p.person_vorname'
      );
  end;
  fMemberSelectQuery.ParamByName('UnitId').Value := lUnit.Id;
  var lSqlResult := fMemberSelectQuery.Open;
  while lSqlResult.Next do
  begin
    var lMemberRec := default(TDtoUnitAggregatedPersonMemberOf);
    lMemberRec.MemberRecordId := lSqlResult.FieldByName('mb_id').AsLargeInt;
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

  fMemberOfBusiness.LoadMemberOfs(aId);
end;

{ TVersionInfoConfig }

function TVersionInfoConfig.GetRecordIdentity(const aRecord: TDtoUnit): UInt32;
begin
  Result := aRecord.Id;
end;

function TVersionInfoConfig.GetVersioningEntityId: TEntryVersionInfoEntity;
begin
  Result := TEntryVersionInfoEntity.Units;
end;

function TVersionInfoConfig.GetVersioningIdentityColumnName: string;
begin
  Result := 'unit_id';
end;

procedure TVersionInfoConfig.SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
begin
  aParameter.Value := aRecordIdentity;
end;

end.
