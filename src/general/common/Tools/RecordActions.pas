unit RecordActions;

interface

uses System.Generics.Collections, SqlConnection, Transaction, CrudConfig, CrudAccessor;

type
  TRecordActionsSaveResponse = (Created, Updated);

  TRecordActions<TRecord, TRecordIdentity: record> = class
  strict private
    fConnection: ISqlConnection;
    fConfig: ICrudConfig<TRecord, TRecordIdentity>;
    fRecordSelect: ISqlPreparedQuery;
    fInsertAccessor: TCrudAccessorInsert;
    fUpdateAccessor: TCrudAccessorUpdate;
    fDeleteAccessor: TCrudAccessorDelete;
  public
    constructor Create(const aConnection: ISqlConnection; const aConfig: ICrudConfig<TRecord, TRecordIdentity>);
    destructor Destroy; override;
    function LoadRecord(const aRecordIdentity: TRecordIdentity; var aRecord: TRecord): Boolean;
    function SaveRecord(var aRecord: TRecord; aTransaction: ITransaction = nil): TRecordActionsSaveResponse;
    function DeleteRecord(const aRecordIdentity: TRecordIdentity; aTransaction: ITransaction = nil): Boolean;
  end;

implementation

{ TRecordActions<TRecord, TRecordIdentity> }

constructor TRecordActions<TRecord, TRecordIdentity>.Create(const aConnection: ISqlConnection;
  const aConfig: ICrudConfig<TRecord, TRecordIdentity>);
begin
  inherited Create;
  fConnection := aConnection;
  fConfig := aConfig;
  fInsertAccessor := TCrudAccessorInsert.Create(fConnection, fConfig.Tablename, fConfig.GetIdentityColumns);
  fUpdateAccessor := TCrudAccessorUpdate.Create(fConnection, fConfig.Tablename, fConfig.GetIdentityColumns);
  fDeleteAccessor := TCrudAccessorDelete.Create(fConnection, fConfig.Tablename, fConfig.GetIdentityColumns);
end;

destructor TRecordActions<TRecord, TRecordIdentity>.Destroy;
begin
  fDeleteAccessor.Free;
  fUpdateAccessor.Free;
  fInsertAccessor.Free;
  inherited;
end;

function TRecordActions<TRecord, TRecordIdentity>.LoadRecord(const aRecordIdentity: TRecordIdentity;
  var aRecord: TRecord): Boolean;
begin
  Result := False;
  if not Assigned(fRecordSelect) then
  begin
    fRecordSelect := fConnection.CreatePreparedQuery(fConfig.GetSelectSqlRecord);
  end;
  fConfig.SetParametersForLoad(aRecordIdentity, fRecordSelect);
  var lSqlResult := fRecordSelect.Open;
  if lSqlResult.Next then
  begin
    fConfig.SetRecordFromResult(lSqlResult, aRecord);
    Result := True;
  end;
end;

function TRecordActions<TRecord, TRecordIdentity>.SaveRecord(var aRecord: TRecord;
  aTransaction: ITransaction): TRecordActionsSaveResponse;
begin
  var lNewRecordResponse := fConfig.IsNewRecord(aRecord);
  if lNewRecordResponse = TCrudConfigNewRecordResponse.NewRecord then
  begin
    fConfig.SetValues(aRecord, fInsertAccessor, False);
    fInsertAccessor.Insert(aTransaction);
    if fInsertAccessor.AutoIncPresent and (fInsertAccessor.LastInsertedId > 0) then
    begin
      fConfig.UpdateRecordIdentity(fInsertAccessor, aRecord);
    end;
    Result := TRecordActionsSaveResponse.Created;
  end
  else if lNewRecordResponse = TCrudConfigNewRecordResponse.ExistingRecord then
  begin
    fConfig.SetValues(aRecord, fUpdateAccessor, True);
    fUpdateAccessor.Update(aTransaction);
    Result := TRecordActionsSaveResponse.Updated;
  end
  else
  begin
    fConfig.SetValues(aRecord, fUpdateAccessor, True);
    if fUpdateAccessor.Update(aTransaction) then
    begin
      Result := TRecordActionsSaveResponse.Updated;
    end
    else
    begin
      fConfig.SetValues(aRecord, fInsertAccessor, False);
      fInsertAccessor.Insert(aTransaction);
      if fInsertAccessor.AutoIncPresent and (fInsertAccessor.LastInsertedId > 0) then
      begin
        fConfig.UpdateRecordIdentity(fInsertAccessor, aRecord);
      end;
      Result := TRecordActionsSaveResponse.Created;
    end;
  end;
end;

function TRecordActions<TRecord, TRecordIdentity>.DeleteRecord(const aRecordIdentity: TRecordIdentity;
  aTransaction: ITransaction): Boolean;
begin
  Result := True;
  fConfig.SetValuesForDelete(aRecordIdentity, fDeleteAccessor);
  fDeleteAccessor.Delete(aTransaction);
end;

end.
