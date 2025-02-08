unit CrudConfigAddressAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoAddressAggregated, SqlConnection, CrudConfigAddress, CrudConfig,
  RecordActionsVersioning, DtoAddress, Vdm.Types, Vdm.Versioning.Types, CrudCommands, VersionInfoEntryAccessor;

type
  TCrudConfigAddressAggregated = class(TInterfacedBase,
    IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>,
    IVersionInfoEntryAccessor<TDtoAddressAggregated>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TDtoAddress, UInt32>;
    fVersionInfoConfig: IVersionInfoConfig<TDtoAddress, UInt32>;
    fRecordActions: TRecordActionsVersioning<TDtoAddress, UInt32>;
    fMemberSelectQuery: ISqlPreparedQuery;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoAddress;
    function IsEntryValidForList(const aEntry: TDtoAddress; const aListFilter: TVoid): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoAddressAggregated): Boolean;
    procedure DestroyEntry(var aEntry: TDtoAddressAggregated);
    procedure DestroyListEntry(var aEntry: TDtoAddress);
    procedure StartNewEntry;
    procedure NewEntrySaved(const aEntry: TDtoAddressAggregated);
    function GetIdFromEntry(const aEntry: TDtoAddressAggregated): UInt32;
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoAddressAggregated): Boolean;
    function CreateEntry: TDtoAddressAggregated;
    function CloneEntry(const aEntry: TDtoAddressAggregated): TDtoAddressAggregated;
    function IsEntryUndefined(const aEntry: TDtoAddressAggregated): Boolean;
    function SaveEntry(var aEntry: TDtoAddressAggregated): TCrudSaveResult;
    function DeleteEntry(const aId: UInt32): Boolean;
    function GetEntryTitle(const aPlural: Boolean): string;

    function GetVersionInfoEntry(const aEntry: TDtoAddressAggregated; out aVersionInfoEntry: TVersionInfoEntry): Boolean;
    procedure AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TDtoAddressAggregated);
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList;

type
  TVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<TDtoAddress, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TDtoAddress): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;


{ TCrudConfigAddressAggregated }

constructor TCrudConfigAddressAggregated.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfig := TCrudConfigAddress.Create;
  fVersionInfoConfig := TVersionInfoConfig.Create;
  fRecordActions := TRecordActionsVersioning<TDtoAddress, UInt32>.Create(fConnection, fCrudConfig, fVersionInfoConfig);
end;

destructor TCrudConfigAddressAggregated.Destroy;
begin
  fRecordActions.Free;
  inherited;
end;

function TCrudConfigAddressAggregated.CloneEntry(const aEntry: TDtoAddressAggregated): TDtoAddressAggregated;
begin
  Result := TDtoAddressAggregated.Create(aEntry.Address);
  for var lEntry in aEntry.MemberOfList do
    Result.MemberOfList.Add(lEntry);
  Result.VersionInfo.Assign(aEntry.VersionInfo);
end;

function TCrudConfigAddressAggregated.CreateEntry: TDtoAddressAggregated;
begin
  Result := TDtoAddressAggregated.Create(default(TDtoAddress));
end;

function TCrudConfigAddressAggregated.DeleteEntry(const aId: UInt32): Boolean;
begin
  Result := False;
end;

procedure TCrudConfigAddressAggregated.DestroyEntry(var aEntry: TDtoAddressAggregated);
begin
  FreeAndNil(aEntry);
end;

procedure TCrudConfigAddressAggregated.DestroyListEntry(var aEntry: TDtoAddress);
begin
  aEntry := default(TDtoAddress);
end;

function TCrudConfigAddressAggregated.GetEntryTitle(const aPlural: Boolean): string;
begin
  if aPlural then
    Result := 'Adressen'
  else
    Result := 'Adresse';
end;

function TCrudConfigAddressAggregated.GetIdFromEntry(const aEntry: TDtoAddressAggregated): UInt32;
begin
  Result := aEntry.Id;
end;

function TCrudConfigAddressAggregated.GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoAddress;
begin
  Result := default(TDtoAddress);
  fCrudConfig.GetRecordFromSqlResult(aSqlResult, Result);
end;

function TCrudConfigAddressAggregated.GetListSqlResult: ISqlResult;
begin
  var lSelectList: ISelectList<TDtoAddress>;
  if not Supports(fCrudConfig, ISelectList<TDtoAddress>, lSelectList) then
    raise ENotImplemented.Create('fCrudConfig must implement ISelectList<TDtoAddress>.');
  Result := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
end;

function TCrudConfigAddressAggregated.GetVersionInfoEntry(const aEntry: TDtoAddressAggregated;
  out aVersionInfoEntry: TVersionInfoEntry): Boolean;
begin
  Result := True;
  aVersionInfoEntry := aEntry.VersionInfo;
end;

procedure TCrudConfigAddressAggregated.AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TDtoAddressAggregated);
begin
  aTargetEntry.VersionInfo.Assign(aSourceEntry.VersionInfo);
end;

function TCrudConfigAddressAggregated.IsEntryUndefined(const aEntry: TDtoAddressAggregated): Boolean;
begin
  Result := not Assigned(aEntry);
end;

function TCrudConfigAddressAggregated.IsEntryValidForList(const aEntry: TDtoAddress; const aListFilter: TVoid): Boolean;
begin
  Result := True;
end;

function TCrudConfigAddressAggregated.IsEntryValidForSaving(const aEntry: TDtoAddressAggregated): Boolean;
begin
  Result := True;
end;

procedure TCrudConfigAddressAggregated.NewEntrySaved(const aEntry: TDtoAddressAggregated);
begin

end;

function TCrudConfigAddressAggregated.SaveEntry(var aEntry: TDtoAddressAggregated): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  var lRecord := aEntry.Address;
  var lResponse := fRecordActions.SaveRecord(lRecord, aEntry.VersionInfo);
  if lResponse.VersioningState = TVersioningResponseVersioningState.ConflictDetected then
  begin
    Exit(TCrudSaveResult.CreateConflictedRecord(aEntry.VersionInfo));
  end;
  if lResponse.Kind = TVersioningSaveKind.Created then
  begin
    aEntry.Id := lRecord.Id;
  end;
end;

procedure TCrudConfigAddressAggregated.StartNewEntry;
begin

end;

function TCrudConfigAddressAggregated.TryLoadEntry(const aId: UInt32; out aEntry: TDtoAddressAggregated): Boolean;
begin
  var lRecord := default(TDtoAddress);
  var lResponse := fRecordActions.LoadRecord(aId, lRecord);
  Result := lResponse.Succeeded;
  if not Result then
    Exit;

  aEntry := TDtoAddressAggregated.Create(lRecord);
  aEntry.VersionInfo.UpdateVersionInfo(lResponse.EntryVersionInfo);

  if not Assigned(fMemberSelectQuery) then
  begin
    fMemberSelectQuery := fConnection.CreatePreparedQuery(
        'SELECT p.person_id, p.person_firstname, p.person_nameaddition, p.person_lastname' +
        ' FROM person_address AS pa' +
        ' INNER JOIN person AS p ON p.person_id = pa.person_id' +
        ' WHERE pa.adr_id = :AdrId' +
        ' AND p.person_active = 1' +
        ' ORDER BY p.person_lastname, p.person_firstname'
      );
  end;
  fMemberSelectQuery.ParamByName('AdrId').Value := lRecord.Id;
  var lSqlResult := fMemberSelectQuery.Open;
  while lSqlResult.Next do
  begin
    var lMemberRec := default(TDtoAddressAggregatedPersonMemberOf);
    lMemberRec.PersonNameId.Id := lSqlResult.FieldByName('person_id').AsLargeInt;
    lMemberRec.PersonNameId.Firstname := lSqlResult.FieldByName('person_firstname').AsString;
    lMemberRec.PersonNameId.NameAddition := lSqlResult.FieldByName('person_nameaddition').AsString;
    lMemberRec.PersonNameId.Lastname := lSqlResult.FieldByName('person_lastname').AsString;
    aEntry.MemberOfList.Add(lMemberRec);
  end;
end;

{ TVersionInfoConfig }

function TVersionInfoConfig.GetRecordIdentity(const aRecord: TDtoAddress): UInt32;
begin
  Result := aRecord.Id;
end;

function TVersionInfoConfig.GetVersioningEntityId: TEntryVersionInfoEntity;
begin
  Result := TEntryVersionInfoEntity.Addresses;
end;

function TVersionInfoConfig.GetVersioningIdentityColumnName: string;
begin
  Result := 'adr_id';
end;

procedure TVersionInfoConfig.SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
begin
  aParameter.Value := aRecordIdentity;
end;

end.
