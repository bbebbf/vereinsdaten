unit DefaultCrudCommands;

interface

uses System.Generics.Collections, System.SysUtils, Data.DB, SqlConnection,
  CrudCommands, CrudUI, CrudConfig, RecordActions;

type
  TDefaultCrudCommands<TRecord, TRecordIdentity: record> = class(TInterfacedObject, ICrudCommands<TRecordIdentity>)
  strict private
    fConnection: ISqlConnection;
    fConfig: ICrudConfig<TRecord, TRecordIdentity>;
    fUI: ICrudUI<TRecord, TRecordIdentity>;
    fRecordActions: TRecordActions<TRecord, TRecordIdentity>;
    fCurrrentRecord: TRecord;

    function LoadList: TCrudCommandResult;
    procedure Initialize;
    function LoadCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
    function SaveCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
    function ReloadCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
    function DeleteRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
  public
    constructor Create(aConnection: ISqlConnection; aConfig: ICrudConfig<TRecord, TRecordIdentity>;
      aUI: ICrudUI<TRecord, TRecordIdentity>);
    destructor Destroy; override;
    property Connection: ISqlConnection read fConnection;
  end;

implementation

{ TDefaultCrudCommands<TRecord, TRecordIdentity> }

constructor TDefaultCrudCommands<TRecord, TRecordIdentity>.Create(aConnection: ISqlConnection;
  aConfig: ICrudConfig<TRecord, TRecordIdentity>; aUI: ICrudUI<TRecord, TRecordIdentity>);
begin
  inherited Create;
  fConnection := aConnection;
  fConfig := aConfig;
  fUI := aUI;
  fRecordActions := TRecordActions<TRecord, TRecordIdentity>.Create(fConnection, fConfig);
end;

destructor TDefaultCrudCommands<TRecord, TRecordIdentity>.Destroy;
begin
  fRecordActions.Free;
  inherited;
end;

procedure TDefaultCrudCommands<TRecord, TRecordIdentity>.Initialize;
begin
  fUI.Initialize(Self);
end;

function TDefaultCrudCommands<TRecord, TRecordIdentity>.DeleteRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fRecordActions.DeleteRecord(aRecordIdentity);
  fUI.DeleteRecordfromUI(aRecordIdentity);
end;

function TDefaultCrudCommands<TRecord, TRecordIdentity>.LoadList: TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  var lRecords := TList<TRecord>.Create;
  try
    var lSqlResult := fConnection.GetSelectResult(fConfig.GetSelectSqlList);
    while lSqlResult.Next do
    begin
      var lRecord := default(TRecord);
      fConfig.SetRecordFromResult(lSqlResult, lRecord);
      lRecords.Add(lRecord);
    end;
    fUI.LoadUIList(lRecords);
  finally
    lRecords.Free;
  end;
end;

function TDefaultCrudCommands<TRecord, TRecordIdentity>.ReloadCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
end;

function TDefaultCrudCommands<TRecord, TRecordIdentity>.LoadCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  if fRecordActions.LoadRecord(aRecordIdentity, fCurrrentRecord) then
  begin
    fUI.SetRecordToUI(fCurrrentRecord);
  end
  else
  begin
    fUI.DeleteRecordfromUI(aRecordIdentity);
    fUI.ClearRecordUI;
  end;
end;

function TDefaultCrudCommands<TRecord, TRecordIdentity>.SaveCurrentRecord(const aRecordIdentity: TRecordIdentity): TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fUI.GetRecordFromUI(fCurrrentRecord);
  fRecordActions.SaveRecord(fCurrrentRecord);
  fUI.SetRecordToUI(fCurrrentRecord);
end;

end.
