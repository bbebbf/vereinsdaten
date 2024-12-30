unit RecordActionsVersioning;

interface

uses System.Generics.Collections, SqlConnection, Transaction, CrudConfig, CrudAccessor, RecordActions,
  Vdm.Versioning.Types, VersionInfoAccessor;

type
  TRecordActionsVersioningResponseVersioningState = (NoConflict, ConflictDetected, VersionUpdated, InvalidVersionInfo);

  TRecordActionsVersioningLoadResponse = record
    Succeeded: Boolean;
    EntryVersionInfo: TEntryVersionInfo;
  end;

  TRecordActionsVersioningSaveKind = (Created, Updated);
  TRecordActionsVersioningSaveResponse = record
    Kind: TRecordActionsVersioningSaveKind;
    VersioningState: TRecordActionsVersioningResponseVersioningState;
    ConflictedEntryVersionInfo: TEntryVersionInfo;
  end;

  TRecordActionsVersioningDeleteResponse = record
    Succeeded: Boolean;
    VersioningState: TRecordActionsVersioningResponseVersioningState;
    ConflictedEntryVersionInfo: TEntryVersionInfo;
  end;

  TRecordActionsVersioning<TRecord, TRecordIdentity: record> = class
  strict private
    fConnection: ISqlConnection;
    fVersionInfoAccessor: TVersionInfoAccessor<TRecord, TRecordIdentity>;
    fRecordActions: TRecordActions<TRecord, TRecordIdentity>;
  public
    constructor Create(const aConnection: ISqlConnection;
      const aConfig: ICrudConfig<TRecord, TRecordIdentity>;
      const aVersionInfoConfig: IVersionInfoConfig<TRecord, TRecordIdentity>);
    destructor Destroy; override;
    function LoadRecord(const aRecordIdentity: TRecordIdentity; var aRecord: TRecord;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningLoadResponse;
    function SaveRecord(var aRecord: TRecord; const aVersionInfoEntry: TVersionInfoEntry;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningSaveResponse;
    function DeleteEntry(const aRecordIdentity: TRecordIdentity; const aVersionInfoEntry: TVersionInfoEntry;
      const aTransaction: ITransaction = nil): TRecordActionsVersioningDeleteResponse;
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
  fRecordActions := TRecordActions<TRecord, TRecordIdentity>.Create(fConnection, aConfig);
  fVersionInfoAccessor := TVersionInfoAccessor<TRecord, TRecordIdentity>.Create(fConnection, aVersionInfoConfig);
end;

destructor TRecordActionsVersioning<TRecord, TRecordIdentity>.Destroy;
begin
  fVersionInfoAccessor.Free;
  fRecordActions.Free;
  fConnection := nil;
  inherited;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.LoadRecord(const aRecordIdentity: TRecordIdentity;
  var aRecord: TRecord; const aTransaction: ITransaction): TRecordActionsVersioningLoadResponse;
begin
  Result := default(TRecordActionsVersioningLoadResponse);
  var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
  if fRecordActions.LoadRecord(aRecordIdentity, aRecord, lTransactionResult.Transaction) then
  begin
    Result.Succeeded := True;
    Result.EntryVersionInfo := fVersionInfoAccessor.QueryVersionInfo(lTransactionResult, aRecordIdentity);
  end
  else
  begin
    Result.Succeeded := True;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.SaveRecord(var aRecord: TRecord;
  const aVersionInfoEntry: TVersionInfoEntry; const aTransaction: ITransaction): TRecordActionsVersioningSaveResponse;
begin
  Result := default(TRecordActionsVersioningSaveResponse);
  var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
  case fRecordActions.SaveRecord(aRecord, lTransactionResult.Transaction) of
    TRecordActionsSaveResponse.Created:
    begin
      Result.Kind := TRecordActionsVersioningSaveKind.Created;
      aVersionInfoEntry.Reset;
    end;
    TRecordActionsSaveResponse.Updated:
    begin
      Result.Kind := TRecordActionsVersioningSaveKind.Updated;
    end;
  end;

  if fVersionInfoAccessor.UpdateVersionInfo(lTransactionResult, aRecord, aVersionInfoEntry) then
  begin
    Result.VersioningState := TRecordActionsVersioningResponseVersioningState.VersionUpdated;
  end
  else
  begin
    Result.VersioningState := TRecordActionsVersioningResponseVersioningState.ConflictDetected;
    lTransactionResult.RollbackOnVersionConflict;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.DeleteEntry(const aRecordIdentity: TRecordIdentity;
  const aVersionInfoEntry: TVersionInfoEntry; const aTransaction: ITransaction): TRecordActionsVersioningDeleteResponse;
begin
  Result := default(TRecordActionsVersioningDeleteResponse);
  var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
  if aVersionInfoEntry.LocalVersionInfo.Id = 0 then
  begin
    Result.VersioningState := TRecordActionsVersioningResponseVersioningState.InvalidVersionInfo;
    lTransactionResult.RollbackOnVersionConflict;
    Exit;
  end;

  if not fVersionInfoAccessor.DeleteVersionInfo(lTransactionResult, aVersionInfoEntry) then
  begin
    Result.VersioningState := TRecordActionsVersioningResponseVersioningState.ConflictDetected;
    lTransactionResult.RollbackOnVersionConflict;
    Exit;
  end;

  Result.Succeeded := fRecordActions.DeleteEntry(aRecordIdentity, aTransaction);
end;

end.
