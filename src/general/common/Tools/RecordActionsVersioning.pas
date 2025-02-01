unit RecordActionsVersioning;

interface

uses System.Generics.Collections, SqlConnection, Transaction, CrudConfig, CrudAccessor, RecordActions,
  Vdm.Versioning.Types, VersionInfoAccessor;

type
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
      const aTransaction: ITransaction = nil): TVersioningLoadResponse;
    function SaveRecord(var aRecord: TRecord; const aVersionInfoEntry: TVersionInfoEntry;
      const aTransaction: ITransaction = nil): TVersioningSaveResponse;
    function DeleteEntry(const aRecordIdentity: TRecordIdentity; const aVersionInfoEntry: TVersionInfoEntry;
      const aTransaction: ITransaction = nil): TVersioningDeleteResponse;
    function VersioningActive: Boolean;
    property VersionInfoAccessor: TVersionInfoAccessor<TRecord, TRecordIdentity> read fVersionInfoAccessor;
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
  if Assigned(aVersionInfoConfig) then
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
  var aRecord: TRecord; const aTransaction: ITransaction): TVersioningLoadResponse;
begin
  Result := default(TVersioningLoadResponse);
  if Assigned(fVersionInfoAccessor) then
  begin
    var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
    if fRecordActions.LoadRecord(aRecordIdentity, aRecord, lTransactionResult.Transaction) then
    begin
      Result.Succeeded := True;
      Result.EntryVersionInfo := fVersionInfoAccessor.QueryVersionInfo(lTransactionResult, aRecordIdentity);
    end;
  end
  else
  begin
    if fRecordActions.LoadRecord(aRecordIdentity, aRecord, aTransaction) then
    begin
      Result.Succeeded := True;
    end;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.SaveRecord(var aRecord: TRecord;
  const aVersionInfoEntry: TVersionInfoEntry; const aTransaction: ITransaction): TVersioningSaveResponse;
begin
  Result := default(TVersioningSaveResponse);
  if Assigned(fVersionInfoAccessor) and Assigned(aVersionInfoEntry) then
  begin
    var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
    case fRecordActions.SaveRecord(aRecord, lTransactionResult.Transaction) of
      TRecordActionsSaveResponse.Created:
      begin
        Result.Kind := TVersioningSaveKind.Created;
        aVersionInfoEntry.Reset;
      end;
      TRecordActionsSaveResponse.Updated:
      begin
        Result.Kind := TVersioningSaveKind.Updated;
      end;
    end;

    if fVersionInfoAccessor.UpdateVersionInfo(lTransactionResult, aRecord, aVersionInfoEntry) then
    begin
      Result.VersioningState := TVersioningResponseVersioningState.VersionUpdated;
    end
    else
    begin
      Result.VersioningState := TVersioningResponseVersioningState.ConflictDetected;
      lTransactionResult.RollbackOnVersionConflict;
    end;
  end
  else
  begin
    case fRecordActions.SaveRecord(aRecord, aTransaction) of
      TRecordActionsSaveResponse.Created:
      begin
        Result.Kind := TVersioningSaveKind.Created;
        aVersionInfoEntry.Reset;
      end;
      TRecordActionsSaveResponse.Updated:
      begin
        Result.Kind := TVersioningSaveKind.Updated;
      end;
    end;
  end;
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.VersioningActive: Boolean;
begin
  Result := Assigned(fVersionInfoAccessor);
end;

function TRecordActionsVersioning<TRecord, TRecordIdentity>.DeleteEntry(const aRecordIdentity: TRecordIdentity;
  const aVersionInfoEntry: TVersionInfoEntry; const aTransaction: ITransaction): TVersioningDeleteResponse;
begin
  Result := default(TVersioningDeleteResponse);
  if Assigned(fVersionInfoAccessor) and Assigned(aVersionInfoEntry) then
  begin
    var lTransactionResult := fVersionInfoAccessor.StartTransaction(aTransaction);
    if aVersionInfoEntry.LocalVersionInfo.Id = 0 then
    begin
      Result.VersioningState := TVersioningResponseVersioningState.InvalidVersionInfo;
      lTransactionResult.RollbackOnVersionConflict;
      Exit;
    end;

    if not fVersionInfoAccessor.DeleteVersionInfo(lTransactionResult, aVersionInfoEntry) then
    begin
      Result.VersioningState := TVersioningResponseVersioningState.ConflictDetected;
      lTransactionResult.RollbackOnVersionConflict;
      Exit;
    end;

    Result.Succeeded := fRecordActions.DeleteEntry(aRecordIdentity, lTransactionResult.Transaction);
  end
  else
  begin
    Result.Succeeded := fRecordActions.DeleteEntry(aRecordIdentity, aTransaction);
  end;
end;

end.
