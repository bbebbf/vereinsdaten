unit RecordActionsVersioning;

interface

uses System.Generics.Collections, SqlConnection, Transaction, CrudConfig, CrudAccessor, RecordActions,
  Vdm.Versioning.Types, VersionInfoConfig;

type
  TRecordActionsVersioningResponseState = (Undefined, LoadSucceeded, LoadFailed,
    SaveSucceededCreated, SaveSucceededUpdated, SaveFailed,
    DeleteSucceeded, DeleteFailed);
  TRecordActionsVersioningResponseVersioningState = (NoConflict, ConflictDetected, VersionUpdated, InvalidVersionInfo);
  TRecordActionsVersioningResponse = record
    State: TRecordActionsVersioningResponseState;
    VersioningState: TRecordActionsVersioningResponseVersioningState;
    EntryVersionInfo: TEntryVersionInfo;
  end;

  TRecordActionsVersioning<TRecord, TRecordIdentity: record> = class
  strict private
    fConnection: ISqlConnection;
    fVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>;
    fSelectVersioninfoQuery: ISqlPreparedQuery;
    fSelectVersioninfoQueryById: ISqlPreparedQuery;
    fInsertVersioninfoCommand: ISqlPreparedCommand;
    fUpdateVersioninfoCommand: ISqlPreparedCommand;
    fDeleteVersioninfoCommand: ISqlPreparedCommand;
    fRecordActions: TRecordActions<TRecord, TRecordIdentity>;
    function StartTransaction(const aTransaction: ITransaction): TPair<Boolean, ITransaction>;
    procedure CommitTransaction(const aTransactionData: TPair<Boolean, ITransaction>);
    procedure RollbackTransactionOnConflict(var aTransactionData: TPair<Boolean, ITransaction>);
    function QueryVersionInfo(const aTransaction: ITransaction; const aRecordIdentity: TRecordIdentity): TEntryVersionInfo;
    function SqlResultToVersionInfo(const aSqlResult: ISqlResult): TEntryVersionInfo;
    function UpdateVersionInfo(const aTransaction: ITransaction; const aRecordIdentity: TRecordIdentity;
      var aEntryVersionInfo: TEntryVersionInfo): Boolean;
    function DeleteVersionInfo(const aTransaction: ITransaction; var aEntryVersionInfo: TEntryVersionInfo): Boolean;
  public
    constructor Create(const aConnection: ISqlConnection;
      const aConfig: ICrudConfig<TRecord, TRecordIdentity>;
      const aVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>);
    destructor Destroy; override;
    function LoadRecord(const aRecordIdentity: TRecordIdentity; var aRecord: TRecord;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningResponse;
    function SaveRecord(var aRecord: TRecord; var aEntryVersionInfo: TEntryVersionInfo;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningResponse;
    function DeleteEntry(const aRecordIdentity: TRecordIdentity; var aEntryVersionInfo: TEntryVersionInfo;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningResponse;
  end;

implementation

uses System.SysUtils, System.DateUtils;

{ TRecordActionsVersioning<TRecord, TRecordIdentity> }

constructor TRecordActionsVersioning<TRecord, TRecordIdentity>.Create(const aConnection: ISqlConnection;
  const aConfig: ICrudConfig<TRecord, TRecordIdentity>;
  const aVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>);
begin
  inherited Create;
  fConnection := aConnection;
  fVersionInfoConfig := aVersionInfoConfig;
  fRecordActions := TRecordActions<TRecord, TRecordIdentity>.Create(fConnection, aConfig);
end;

destructor TRecordActionsVersioning<TRecord, TRecordIdentity>.Destroy;
begin
  fRecordActions.Free;
  fConnection := nil;
  inherited;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.LoadRecord(const aRecordIdentity: TRecordIdentity;
  var aRecord: TRecord; const aTransaction: ITransaction): TRecordActionsVersioningResponse;
begin
  Result := default(TRecordActionsVersioningResponse);
  var lTransactionResult := StartTransaction(aTransaction);
  try
    if fRecordActions.LoadRecord(aRecordIdentity, aRecord) then
    begin
      Result.State := TRecordActionsVersioningResponseState.LoadSucceeded;
      Result.EntryVersionInfo := QueryVersionInfo(lTransactionResult.Value, aRecordIdentity);
    end
    else
    begin
      Result.State := TRecordActionsVersioningResponseState.LoadFailed;
    end;
  finally
    CommitTransaction(lTransactionResult);
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.SaveRecord(var aRecord: TRecord;
  var aEntryVersionInfo: TEntryVersionInfo; const aTransaction: ITransaction): TRecordActionsVersioningResponse;
begin
  Result := default(TRecordActionsVersioningResponse);
  var lTransactionResult := StartTransaction(aTransaction);
  try
    case fRecordActions.SaveRecord(aRecord, aTransaction) of
      TRecordActionsSaveResponse.Created:
      begin
        Result.State := TRecordActionsVersioningResponseState.SaveSucceededCreated;
        aEntryVersionInfo := default(TEntryVersionInfo);
      end;
      TRecordActionsSaveResponse.Updated:
      begin
        Result.State := TRecordActionsVersioningResponseState.SaveSucceededUpdated;
      end;
    end;
    Result.EntryVersionInfo := aEntryVersionInfo;
    if UpdateVersionInfo(lTransactionResult.Value, fVersionInfoConfig.GetRecordIdentity(aRecord), Result.EntryVersionInfo) then
    begin
      Result.VersioningState := TRecordActionsVersioningResponseVersioningState.VersionUpdated;
    end
    else
    begin
      Result.VersioningState := TRecordActionsVersioningResponseVersioningState.ConflictDetected;
      RollbackTransactionOnConflict(lTransactionResult);
      Exit;
    end;
  finally
    aEntryVersionInfo := Result.EntryVersionInfo;
    CommitTransaction(lTransactionResult);
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.DeleteEntry(const aRecordIdentity: TRecordIdentity;
  var aEntryVersionInfo: TEntryVersionInfo; const aTransaction: ITransaction): TRecordActionsVersioningResponse;
begin
  Result := default(TRecordActionsVersioningResponse);
  var lTransactionResult := StartTransaction(aTransaction);
  try
    if aEntryVersionInfo.Id = 0 then
    begin
      Result.State := TRecordActionsVersioningResponseState.DeleteFailed;
      Result.VersioningState := TRecordActionsVersioningResponseVersioningState.InvalidVersionInfo;
      RollbackTransactionOnConflict(lTransactionResult);
      Exit;
    end;

    Result.EntryVersionInfo := aEntryVersionInfo;
    if not DeleteVersionInfo(lTransactionResult.Value, Result.EntryVersionInfo) then
    begin
      Result.State := TRecordActionsVersioningResponseState.DeleteFailed;
      Result.VersioningState := TRecordActionsVersioningResponseVersioningState.ConflictDetected;
      RollbackTransactionOnConflict(lTransactionResult);
      Exit;
    end;

    aEntryVersionInfo := Result.EntryVersionInfo;
    if fRecordActions.DeleteEntry(aRecordIdentity, aTransaction) then
    begin
      Result.State := TRecordActionsVersioningResponseState.DeleteSucceeded;
    end
    else
    begin
      Result.State := TRecordActionsVersioningResponseState.DeleteFailed;
    end;
  finally
    CommitTransaction(lTransactionResult);
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.QueryVersionInfo(const aTransaction: ITransaction;
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
    fSelectVersioninfoQuery := fConnection.CreatePreparedQuery(lSelectStr, aTransaction);
  end;
  fSelectVersioninfoQuery.ParamByName('EntityId').Value := Ord(fVersionInfoConfig.GetVersioningEntityId);
  fVersionInfoConfig.SetVersionInfoParameter(aRecordIdentity, fSelectVersioninfoQuery.ParamByName('DataId'));
  var lSqlResult := fSelectVersioninfoQuery.Open;
  if lSqlResult.Next then
  begin
    Result := SqlResultToVersionInfo(lSqlResult);
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.UpdateVersionInfo(const aTransaction: ITransaction;
  const aRecordIdentity: TRecordIdentity; var aEntryVersionInfo: TEntryVersionInfo): Boolean;
begin
  Result := False;
  var lLastUpdated := Now;
  var lVersionNumberNew: UInt32 := 1;
  if aEntryVersionInfo.Id > 0 then
  begin
    if not Assigned(fUpdateVersioninfoCommand) then
    begin
      var lCommandStr := 'UPDATE version_info SET versioninfo_number = :NewNumber' +
        ', versioninfo_lastupdated_utc = :LastupdatedUtc' +
        ' WHERE versioninfo_id = :Id AND versioninfo_number = :ExistingNumber';
      fUpdateVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr, aTransaction);
    end;
    lVersionNumberNew := lVersionNumberNew + aEntryVersionInfo.VersionNumber;
    fUpdateVersioninfoCommand.ParamByName('NewNumber').Value := lVersionNumberNew;
    fUpdateVersioninfoCommand.ParamByName('LastupdatedUtc').Value := TTimeZone.Local.ToUniversalTime(lLastUpdated);
    fUpdateVersioninfoCommand.ParamByName('Id').Value := aEntryVersionInfo.Id;
    fUpdateVersioninfoCommand.ParamByName('ExistingNumber').Value := aEntryVersionInfo.VersionNumber;
    if fUpdateVersioninfoCommand.Execute > 0 then
    begin
      aEntryVersionInfo.VersionNumber := lVersionNumberNew;
      aEntryVersionInfo.LastUpdated := lLastUpdated;
      Result := True;
    end
    else
    begin
      aEntryVersionInfo := QueryVersionInfo(aTransaction, aRecordIdentity);
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
      fInsertVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr, aTransaction);
    end;
    aEntryVersionInfo := default(TEntryVersionInfo);
    fInsertVersioninfoCommand.ParamByName('NewNumber').Value := lVersionNumberNew;
    fInsertVersioninfoCommand.ParamByName('LastupdatedUtc').Value := TTimeZone.Local.ToUniversalTime(lLastUpdated);
    fInsertVersioninfoCommand.ParamByName('EntityId').Value := Ord(fVersionInfoConfig.GetVersioningEntityId);
    fVersionInfoConfig.SetVersionInfoParameter(aRecordIdentity, fInsertVersioninfoCommand.ParamByName('DataId'));
    if fInsertVersioninfoCommand.Execute > 0 then
    begin
      aEntryVersionInfo.Id := fConnection.GetLastInsertedIdentityScoped;
      aEntryVersionInfo.VersionNumber := lVersionNumberNew;
      aEntryVersionInfo.LastUpdated := lLastUpdated;
      Result := True;
    end
    else
    begin
      aEntryVersionInfo := QueryVersionInfo(aTransaction, aRecordIdentity);
    end;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.DeleteVersionInfo(const aTransaction: ITransaction;
  var aEntryVersionInfo: TEntryVersionInfo): Boolean;
begin
  Result := False;
  if not Assigned(fDeleteVersioninfoCommand) then
  begin
    var lCommandStr := 'DELETE FROM version_info WHERE versioninfo_id = :Id' +
      ' AND versioninfo_number = :ExistingNumber';
    fDeleteVersioninfoCommand := fConnection.CreatePreparedCommand(lCommandStr, aTransaction);
  end;
  fDeleteVersioninfoCommand.ParamByName('Id').Value := aEntryVersionInfo.Id;
  fDeleteVersioninfoCommand.ParamByName('ExistingNumber').Value := aEntryVersionInfo.VersionNumber;
  if fDeleteVersioninfoCommand.Execute > 0 then
  begin
    aEntryVersionInfo := default(TEntryVersionInfo);
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
      fSelectVersioninfoQueryById := fConnection.CreatePreparedQuery(lSelectStr, aTransaction);
    end;
    fSelectVersioninfoQueryById.ParamByName('Id').Value := aEntryVersionInfo.Id;
    var lSqlResult := fSelectVersioninfoQuery.Open;
    if lSqlResult.Next then
    begin
      aEntryVersionInfo := SqlResultToVersionInfo(lSqlResult);
    end;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.SqlResultToVersionInfo(
  const aSqlResult: ISqlResult): TEntryVersionInfo;
begin
  Result := default(TEntryVersionInfo);
  Result.Id := aSqlResult.FieldByName('versioninfo_id').AsLargeInt;
  Result.Versionnumber := aSqlResult.FieldByName('versioninfo_number').AsLargeInt;
  Result.LastUpdated := TTimeZone.Local.ToLocalTime(aSqlResult.FieldByName('versioninfo_lastupdated_utc').AsDateTime);
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.StartTransaction(
  const aTransaction: ITransaction): TPair<Boolean, ITransaction>;
begin
  if Assigned(aTransaction) then
    Exit(TPair<Boolean, ITransaction>.Create(False, aTransaction));

  Result := TPair<Boolean, ITransaction>.Create(True, fConnection.StartTransaction);
end;

procedure TRecordActionsVersioning<TRecord, TRecordIdentity>.CommitTransaction(
  const aTransactionData: TPair<Boolean, ITransaction>);
begin
  if aTransactionData.Key then
    aTransactionData.Value.Commit;
end;

procedure TRecordActionsVersioning<TRecord, TRecordIdentity>.RollbackTransactionOnConflict(
  var aTransactionData: TPair<Boolean, ITransaction>);
begin
  aTransactionData.Value.Rollback;
  aTransactionData.Key := False;
end;

end.
