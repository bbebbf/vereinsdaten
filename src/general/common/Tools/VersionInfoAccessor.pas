unit VersionInfoAccessor;


interface

uses Vdm.Versioning.Types, InterfacedBase, Transaction, SqlConnection;

type
  IVersionInfoAccessorTransactionScope = interface
    ['{EDC73D1F-32B1-4CC7-AB2D-D6B1B0E058C3}']
    procedure RollbackOnVersionConflict;
    function GetTranscation: ITransaction;
    function GetRollbackOnVersionConflictCalled: Boolean;
    property Transaction: ITransaction read GetTranscation;
    property RollbackOnVersionConflictCalled: Boolean read GetRollbackOnVersionConflictCalled;
  end;

  TVersionInfoAccessor<TRecord, TRecordIdentity> = class
  strict private
    fConnection: ISqlConnection;
    fVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>;
    fSelectVersioninfoQuery: ISqlPreparedQuery;
    fSelectVersioninfoQueryById: ISqlPreparedQuery;
    fInsertVersioninfoCommand: ISqlPreparedCommand;
    fUpdateVersioninfoCommand: ISqlPreparedCommand;
    fDeleteVersioninfoCommand: ISqlPreparedCommand;
    function SqlResultToVersionInfo(const aSqlResult: ISqlResult): TEntryVersionInfo;
  public
    constructor Create(const aConnection: ISqlConnection;
      const aVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>);
    function StartTransaction(const aTransaction: ITransaction = nil): IVersionInfoAccessorTransactionScope;
    function QueryVersionInfo(const aTransactionInfo: IVersionInfoAccessorTransactionScope;
      const aRecordIdentity: TRecordIdentity): TEntryVersionInfo;
    function UpdateVersionInfo(const aTransactionInfo: IVersionInfoAccessorTransactionScope;
      const aRecord: TRecord; const aVersionInfoEntry: TVersionInfoEntry): Boolean;
    function DeleteVersionInfo(const aTransactionInfo: IVersionInfoAccessorTransactionScope;
      const aVersionInfoEntry: TVersionInfoEntry): Boolean;
  end;

  TVersionInfoAccessorTransactionScope = class(TInterfacedBase, IVersionInfoAccessorTransactionScope)
  strict private
    fConnection: ISqlConnection;
    fTransaction: ITransaction;
    fOwmsTransaction: Boolean;
    fRollbackOnVersionConflictCalled: Boolean;
    function GetTranscation: ITransaction;
    function GetRollbackOnVersionConflictCalled: Boolean;
    procedure RollbackOnVersionConflict;
  public
    constructor Create(const aConnection: ISqlConnection; const aTransaction: ITransaction);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, System.DateUtils;

{ TVersionInfoAccessor<TRecord, TRecordIdentity> }

constructor TVersionInfoAccessor<TRecord, TRecordIdentity>.Create(const aConnection: ISqlConnection;
  const aVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>);
begin
  inherited Create;
  fConnection := aConnection;
  fVersionInfoConfig := aVersionInfoConfig;
end;

function TVersionInfoAccessor<TRecord, TRecordIdentity>.QueryVersionInfo(
  const aTransactionInfo: IVersionInfoAccessorTransactionScope;
  const aRecordIdentity: TRecordIdentity): TEntryVersionInfo;
begin
  Result := default(TEntryVersionInfo);
  if not Assigned(fSelectVersioninfoQuery) then
  begin
    var lColumnName := fVersionInfoConfig.GetVersioningIdentityColumnName;
    var lSelectStr := 'SELECT versioninfo_id, versioninfo_number, versioninfo_lastupdated_utc' +
      ' FROM version_info' +
      ' WHERE versioninfo_entity = :EntityId' +
      ' AND ' + lColumnName + ' = :DataId';
    fSelectVersioninfoQuery := fConnection.CreatePreparedQuery(lSelectStr);
  end;
  fSelectVersioninfoQuery.ParamByName('EntityId').Value := Ord(fVersionInfoConfig.GetVersioningEntityId);
  fVersionInfoConfig.SetVersionInfoParameter(aRecordIdentity, fSelectVersioninfoQuery.ParamByName('DataId'));
  var lSqlResult := fSelectVersioninfoQuery.Open(aTransactionInfo.Transaction);
  if lSqlResult.Next then
  begin
    Result := SqlResultToVersionInfo(lSqlResult);
  end;
end;

function TVersionInfoAccessor<TRecord, TRecordIdentity>.UpdateVersionInfo(
  const aTransactionInfo: IVersionInfoAccessorTransactionScope;
  const aRecord: TRecord; const aVersionInfoEntry: TVersionInfoEntry): Boolean;
begin
  Result := False;
  var lLastUpdated := Now;
  var lVersionNumberNew: UInt32 := 1;
  var lRecordIdentity := fVersionInfoConfig.GetRecordIdentity(aRecord);
  var lUpdatedVersionInfo := aVersionInfoEntry.LocalVersionInfo;
  if lUpdatedVersionInfo.Id > 0 then
  begin
    if not Assigned(fUpdateVersioninfoCommand) then
    begin
      var lCommandStr := 'UPDATE version_info SET versioninfo_number = :NewNumber' +
        ', versioninfo_lastupdated_utc = :LastupdatedUtc' +
        ' WHERE versioninfo_id = :Id AND versioninfo_number = :ExistingNumber';
      fUpdateVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr);
    end;
    lVersionNumberNew := lVersionNumberNew + aVersionInfoEntry.LocalVersionInfo.VersionNumber;
    fUpdateVersioninfoCommand.ParamByName('NewNumber').Value := lVersionNumberNew;
    fUpdateVersioninfoCommand.ParamByName('LastupdatedUtc').Value := TTimeZone.Local.ToUniversalTime(lLastUpdated);
    fUpdateVersioninfoCommand.ParamByName('Id').Value := aVersionInfoEntry.LocalVersionInfo.Id;
    fUpdateVersioninfoCommand.ParamByName('ExistingNumber').Value := aVersionInfoEntry.LocalVersionInfo.VersionNumber;
    if fUpdateVersioninfoCommand.Execute(aTransactionInfo.Transaction) > 0 then
    begin
      lUpdatedVersionInfo.VersionNumber := lVersionNumberNew;
      lUpdatedVersionInfo.LastUpdated := lLastUpdated;
      aVersionInfoEntry.UpdateVersionInfo(lUpdatedVersionInfo);
      Result := True;
    end
    else
    begin
      aVersionInfoEntry.RegisterVersionConflict(QueryVersionInfo(aTransactionInfo, lRecordIdentity));
    end;
  end
  else
  begin
    if not Assigned(fInsertVersioninfoCommand) then
    begin
      var lColumnName := fVersionInfoConfig.GetVersioningIdentityColumnName;
      var lCommandStr := 'INSERT INTO version_info(' + lColumnName +
        ', versioninfo_entity' +
        ', versioninfo_number' +
        ', versioninfo_lastupdated_utc)' +
        ' VALUES(:DataId, :EntityId, :NewNumber, :LastupdatedUtc)';
      fInsertVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr);
    end;
    aVersionInfoEntry.Reset;
    fInsertVersioninfoCommand.ParamByName('NewNumber').Value := lVersionNumberNew;
    fInsertVersioninfoCommand.ParamByName('LastupdatedUtc').Value := TTimeZone.Local.ToUniversalTime(lLastUpdated);
    fInsertVersioninfoCommand.ParamByName('EntityId').Value := Ord(fVersionInfoConfig.GetVersioningEntityId);
    fVersionInfoConfig.SetVersionInfoParameter(lRecordIdentity, fInsertVersioninfoCommand.ParamByName('DataId'));

    var lInsertSucessful: Boolean;
    try
      lInsertSucessful := fInsertVersioninfoCommand.Execute(aTransactionInfo.Transaction) = 1;
    except
      lInsertSucessful := False;
    end;
    if lInsertSucessful then
    begin
      lUpdatedVersionInfo.Id := fConnection.GetLastInsertedIdentityScoped;
      lUpdatedVersionInfo.VersionNumber := lVersionNumberNew;
      lUpdatedVersionInfo.LastUpdated := lLastUpdated;
      aVersionInfoEntry.UpdateVersionInfo(lUpdatedVersionInfo);
      Result := True;
    end
    else
    begin
      aVersionInfoEntry.RegisterVersionConflict(QueryVersionInfo(aTransactionInfo, lRecordIdentity));
    end;
  end;
end;

function TVersionInfoAccessor<TRecord, TRecordIdentity>.DeleteVersionInfo(
  const aTransactionInfo: IVersionInfoAccessorTransactionScope;
  const aVersionInfoEntry: TVersionInfoEntry): Boolean;
begin
  Result := False;
  if not Assigned(fDeleteVersioninfoCommand) then
  begin
    var lCommandStr := 'DELETE FROM version_info WHERE versioninfo_id = :Id' +
      ' AND versioninfo_number = :ExistingNumber';
    fDeleteVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr);
  end;
  fDeleteVersioninfoCommand.ParamByName('Id').Value := aVersionInfoEntry.LocalVersionInfo.Id;
  fDeleteVersioninfoCommand.ParamByName('ExistingNumber').Value := aVersionInfoEntry.LocalVersionInfo.VersionNumber;
  if fDeleteVersioninfoCommand.Execute(aTransactionInfo.Transaction) > 0 then
  begin
    aVersionInfoEntry.Reset;
    Result := True;
  end
  else
  begin
    if not Assigned(fSelectVersioninfoQueryById) then
    begin
      var lColumnName := fVersionInfoConfig.GetVersioningIdentityColumnName;
      var lSelectStr := 'SELECT versioninfo_id, versioninfo_number, versioninfo_lastupdated_utc' +
        ' FROM version_info' +
        ' WHERE versioninfo_id = :Id' +
        ' AND ' + lColumnName + ' = :DataId';
      fSelectVersioninfoQueryById := fConnection.CreatePreparedQuery(lSelectStr);
    end;
    fSelectVersioninfoQueryById.ParamByName('Id').Value := aVersionInfoEntry.LocalVersionInfo.Id;
    var lSqlResult := fSelectVersioninfoQuery.Open(aTransactionInfo.Transaction);
    if lSqlResult.Next then
    begin
      var lVersionInfo := SqlResultToVersionInfo(lSqlResult);
      aVersionInfoEntry.UpdateVersionInfo(lVersionInfo);
    end;
  end;
end;

function TVersionInfoAccessor<TRecord, TRecordIdentity>.StartTransaction(
  const aTransaction: ITransaction): IVersionInfoAccessorTransactionScope;
begin
  Result := TVersionInfoAccessorTransactionScope.Create(fConnection, aTransaction);
end;

function TVersionInfoAccessor<TRecord, TRecordIdentity>.SqlResultToVersionInfo(const aSqlResult: ISqlResult): TEntryVersionInfo;
begin
  Result := default(TEntryVersionInfo);
  Result.Id := aSqlResult.FieldByName('versioninfo_id').AsLargeInt;
  Result.Versionnumber := aSqlResult.FieldByName('versioninfo_number').AsLargeInt;
  Result.LastUpdated := TTimeZone.Local.ToLocalTime(aSqlResult.FieldByName('versioninfo_lastupdated_utc').AsDateTime);
end;

{ TVersionInfoAccessorTransactionScope }

constructor TVersionInfoAccessorTransactionScope.Create(const aConnection: ISqlConnection;
  const aTransaction: ITransaction);
begin
  inherited Create;
  fConnection := aConnection;
  fTransaction := aTransaction;
end;

destructor TVersionInfoAccessorTransactionScope.Destroy;
begin
  if Assigned(fTransaction) and fOwmsTransaction and not fRollbackOnVersionConflictCalled then
  begin
    fTransaction.Commit;
  end;
  inherited;
end;

function TVersionInfoAccessorTransactionScope.GetRollbackOnVersionConflictCalled: Boolean;
begin
  Result := fRollbackOnVersionConflictCalled;
end;

function TVersionInfoAccessorTransactionScope.GetTranscation: ITransaction;
begin
  if not Assigned(fTransaction) then
  begin
    fTransaction := fConnection.StartTransaction;
    fOwmsTransaction := True;
  end;
  Result := fTransaction;
end;

procedure TVersionInfoAccessorTransactionScope.RollbackOnVersionConflict;
begin
  if Assigned(fTransaction) then
  begin
    fTransaction.Rollback;
    fRollbackOnVersionConflictCalled := True;
  end;
end;

end.
