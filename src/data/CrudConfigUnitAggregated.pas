unit CrudConfigUnitAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoUnitAggregated, SqlConnection, CrudConfigUnit, CrudConfig, DtoUnit,
  RecordActionsVersioning, Vdm.Types, Vdm.Versioning.Types, VersionInfoEntryAccessor, CrudCommands,
  MemberOfConfigIntf, MemberOfBusinessIntf, MemberOfUI, ProgressIndicatorIntf;

type
  TCrudConfigUnitAggregated = class(TInterfacedBase,
    IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>,
    IVersionInfoEntryAccessor<TDtoUnitAggregated>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfigUnit: ICrudConfig<TDtoUnit, UInt32>;
    fVersionInfoConfig: IVersionInfoConfig<TDtoUnit, UInt32>;
    fUnitRecordActions: TRecordActionsVersioning<TDtoUnit, UInt32>;
    fMemberOfConfig: IMemberOfConfigIntf;
    fMemberOfBusiness: IMemberOfBusinessIntf;
    fUnitMemberOfsVersionInfoAccessor: IMemberOfsVersioningCrudEvents;

    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoUnit;
    function IsEntryValidForList(const aEntry: TDtoUnit; const aListFilter: TUnitFilter): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoUnitAggregated): Boolean;
    procedure DestroyEntry(var aEntry: TDtoUnitAggregated);
    procedure DestroyListEntry(var aEntry: TDtoUnit);
    procedure StartNewEntry;
    procedure NewEntrySaved(const aEntry: TDtoUnitAggregated);
    function GetIdFromEntry(const aEntry: TDtoUnitAggregated): UInt32;
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoUnitAggregated): Boolean;
    function CreateEntry: TDtoUnitAggregated;
    function CloneEntry(const aEntry: TDtoUnitAggregated): TDtoUnitAggregated;
    function IsEntryUndefined(const aEntry: TDtoUnitAggregated): Boolean;
    function SaveEntry(var aEntry: TDtoUnitAggregated): TCrudSaveResult;
    function DeleteEntry(const aId: UInt32): Boolean;
    function GetEntryTitle(const aPlural: Boolean): string;

    function GetVersionInfoEntry(const aEntry: TDtoUnitAggregated; out aVersionInfoEntry: TVersionInfoEntry): Boolean;
    procedure AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TDtoUnitAggregated);
  public
    constructor Create(const aConnection: ISqlConnection; const aMemberOfUI: IMemberOfUI;
      const aProgressIndicator: IProgressIndicator);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList, Vdm.Globals, MemberOfBusiness, CrudMemberConfigMasterUnit,
  VersionInfoAccessor, Transaction, DtoMemberAggregated, MemberOfVersionInfoConfig;

type
  TVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<TDtoUnit, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TDtoUnit): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;

  TUnitMemberOfsVersionInfoAccessor = class(TInterfacedBase, IMemberOfsVersioningCrudEvents)
  strict private
    fVersionInfoConfig: IVersionInfoConfig<UInt32, UInt32>;
    fVersionInfoAccessor: TVersionInfoAccessor<UInt32, UInt32>;
    fVersionInfoAccessorTransactionScope: IVersionInfoAccessorTransactionScope;
    fConflictedVersionEntry: TVersionInfoEntry;
    procedure BeginLoadEntries(const aTransaction: ITransaction);
    procedure LoadEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure EndLoadEntries(const aTransaction: ITransaction);

    procedure BeginSaveEntries(const aTransaction: ITransaction);
    procedure SaveEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure DeleteEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure EndSaveEntries(const aTransaction: ITransaction);

    function GetVersionConflictDetected: Boolean;
    function GetConflictedVersionEntry: TVersionInfoEntry;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

{ TCrudConfigUnitAggregated }

constructor TCrudConfigUnitAggregated.Create(const aConnection: ISqlConnection; const aMemberOfUI: IMemberOfUI;
  const aProgressIndicator: IProgressIndicator);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfigUnit := TCrudConfigUnit.Create;
  fVersionInfoConfig := TVersionInfoConfig.Create;
  fUnitRecordActions := TRecordActionsVersioning<TDtoUnit, UInt32>.Create(fConnection, fCrudConfigUnit, fVersionInfoConfig);
  fMemberOfConfig := TCrudMemberConfigMasterUnit.Create(fConnection);

  fUnitMemberOfsVersionInfoAccessor := TUnitMemberOfsVersionInfoAccessor.Create(aConnection);
  fMemberOfBusiness := TMemberOfBusiness.Create(fConnection, fMemberOfConfig, fUnitMemberOfsVersionInfoAccessor,
    aMemberOfUI, aProgressIndicator);
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

function TCrudConfigUnitAggregated.GetEntryTitle(const aPlural: Boolean): string;
begin
  if aPlural then
    Result := 'Einheiten'
  else
    Result := 'Einheit';
end;

function TCrudConfigUnitAggregated.GetIdFromEntry(const aEntry: TDtoUnitAggregated): UInt32;
begin
  Result := aEntry.Id;
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

procedure TCrudConfigUnitAggregated.NewEntrySaved(const aEntry: TDtoUnitAggregated);
begin
  fMemberOfBusiness.SetMasterId(aEntry.Id);
end;

function TCrudConfigUnitAggregated.SaveEntry(var aEntry: TDtoUnitAggregated): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  var lUnit := aEntry.&Unit;
  var lResponse := fUnitRecordActions.SaveRecord(lUnit, aEntry.VersionInfo);
  if lResponse.VersioningState = TVersioningResponseVersioningState.ConflictDetected then
  begin
    Exit(TCrudSaveResult.CreateConflictedRecord(aEntry.VersionInfo));
  end;
  if lResponse.Kind = TVersioningSaveKind.Created then
  begin
    aEntry.Id := lUnit.Id;
  end;
end;

procedure TCrudConfigUnitAggregated.StartNewEntry;
begin
  fMemberOfBusiness.LoadMemberOfs(0);
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

{ TUnitMemberOfsVersionInfoAccessor }

constructor TUnitMemberOfsVersionInfoAccessor.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fVersionInfoConfig := TMemberOfVersionInfoConfig.Create;
  fVersionInfoAccessor := TVersionInfoAccessor<UInt32, UInt32>.Create(aConnection, fVersionInfoConfig);
end;

destructor TUnitMemberOfsVersionInfoAccessor.Destroy;
begin
  fVersionInfoAccessor.Free;
  fConflictedVersionEntry.Free;
  inherited;
end;

procedure TUnitMemberOfsVersionInfoAccessor.BeginLoadEntries(const aTransaction: ITransaction);
begin
  fVersionInfoAccessorTransactionScope := fVersionInfoAccessor.StartTransaction(aTransaction);
end;

procedure TUnitMemberOfsVersionInfoAccessor.BeginSaveEntries(const aTransaction: ITransaction);
begin
  FreeAndNil(fConflictedVersionEntry);
  fVersionInfoAccessorTransactionScope := fVersionInfoAccessor.StartTransaction(aTransaction);
end;

procedure TUnitMemberOfsVersionInfoAccessor.EndLoadEntries(const aTransaction: ITransaction);
begin
  fVersionInfoAccessorTransactionScope := nil;
end;

procedure TUnitMemberOfsVersionInfoAccessor.EndSaveEntries(const aTransaction: ITransaction);
begin
  fVersionInfoAccessorTransactionScope := nil;
end;

function TUnitMemberOfsVersionInfoAccessor.GetConflictedVersionEntry: TVersionInfoEntry;
begin
  Result := fConflictedVersionEntry;
end;

function TUnitMemberOfsVersionInfoAccessor.GetVersionConflictDetected: Boolean;
begin
  Result := Assigned(fConflictedVersionEntry);
end;

procedure TUnitMemberOfsVersionInfoAccessor.LoadEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
  aEntry.VersionInfoPersonMemberOf.UpdateVersionInfo(
    fVersionInfoAccessor.QueryVersionInfo(fVersionInfoAccessorTransactionScope, aEntry.Member.PersonId));
end;

procedure TUnitMemberOfsVersionInfoAccessor.SaveEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
  if not fVersionInfoAccessor.UpdateVersionInfo(fVersionInfoAccessorTransactionScope, aEntry.PersonId,
    aEntry.VersionInfoPersonMemberOf) then
  begin
    fVersionInfoAccessorTransactionScope.RollbackOnVersionConflict;
    if not Assigned(fConflictedVersionEntry) then
    begin
      fConflictedVersionEntry := TVersionInfoEntry.Create;
      fConflictedVersionEntry.Assign(aEntry.VersionInfoPersonMemberOf);
    end;
  end;
end;

procedure TUnitMemberOfsVersionInfoAccessor.DeleteEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
  if not fVersionInfoAccessor.DeleteVersionInfo(fVersionInfoAccessorTransactionScope,
    aEntry.VersionInfoPersonMemberOf) then
  begin
    fVersionInfoAccessorTransactionScope.RollbackOnVersionConflict;
    if not Assigned(fConflictedVersionEntry) then
    begin
      fConflictedVersionEntry := TVersionInfoEntry.Create;
      fConflictedVersionEntry.Assign(aEntry.VersionInfoPersonMemberOf);
    end;
  end;
end;

end.
