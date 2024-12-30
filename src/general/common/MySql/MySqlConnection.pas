unit MySqlConnection;

{$I \inc\CompilerDirectives.inc }

interface

uses
  InterfacedBase, Data.DB, SqlConnection, Transaction,
  FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TMySqlResult = class(TInterfacedBase, ISqlResult)
  strict private
    fQuery: TFDCustomQuery;
    fOwnsQuery: Boolean;
    fCursorStarted: Boolean;
    procedure ConfigureDatasource(const aDataSource: TDataSource);
    function GetFieldCount: Integer;
    function Next: Boolean;
    function FieldByName(const aName: string): TField;
    function FieldByIndex(const aIndex: Integer): TField;
    function FieldDefByIndex(const aIndex: Integer): TFieldDef;
  public
    constructor Create(const aQuery: TFDCustomQuery; const aOwnsQuery: Boolean);
    destructor Destroy; override;
  end;

  TMySqlTransaction = class(TInterfacedBase, ITransaction)
  private
    fTransaction: TFDCustomTransaction;
    fWasCommitted: Boolean;
    fWasRollbacked: Boolean;
  strict private
    function GetActive: Boolean;
    function GetWasCommitted: Boolean;
    function GetWasRollbacked: Boolean;
    function Commit: Boolean;
    function Rollback: Boolean;
  public
    constructor Create(const aTransaction: TFDCustomTransaction);
    destructor Destroy; override;
  end;

  TMySqlParameter = class(TInterfacedBase, ISqlParameter)
  private
    fParameter: TFDParam;
  strict private
    function GetName: string;
    function GetDataType: TFieldType;
    procedure SetDataType(const aValue: TFieldType);
    function GetValue: Variant;
    procedure SetValue(const aValue: Variant);
  public
    constructor Create(const aParameter: TFDParam);
  end;

  TMySqlPreparedCommand = class(TInterfacedBase, ISqlPreparedCommand)
  strict private
    fCommand: TFDCommand;
    procedure Prepare;
    function GetParamCount: Integer;
    function ParamByName(const aName: string): ISqlParameter;
    function ParamByIndex(const aIndex: Integer): ISqlParameter;
    function Execute(const aTransaction: ITransaction): Integer;
  public
    constructor Create(const aCommand: TFDCommand);
    destructor Destroy; override;
  end;

  TMySqlPreparedQuery = class(TInterfacedBase, ISqlPreparedQuery)
  strict private
    fQuery: TFDCustomQuery;
    procedure Prepare;
    function GetParamCount: Integer;
    function ParamByName(const aName: string): ISqlParameter;
    function ParamByIndex(const aIndex: Integer): ISqlParameter;
    function Open(const aTransaction: ITransaction): ISqlResult;
  public
    constructor Create(const aQuery: TFDCustomQuery);
    destructor Destroy; override;
  end;

  TMySqlConnectionParameters = class(TSqlConnectionParametersBase)
  public
    function GetConnectionString: string; override;
  end;

  TMySqlConnection = class(TInterfacedBase, ISqlConnection)
  strict private
    fParameters: TSqlConnectionParametersBase;
    fConnection: TFDConnection;
    function GetParameters: TSqlConnectionParametersBase;
    function Connect: Boolean;
    function CreatePreparedCommand(const aSqlCommand: string): ISqlPreparedCommand;
    function CreatePreparedQuery(const aSqlCommand: string): ISqlPreparedQuery;
    function GetSelectResult(const aSqlSelect: string;
      const aTransaction: ITransaction = nil): ISqlResult;
    function ExecuteCommand(const aSqlCommand: string;
      const aTransaction: ITransaction = nil): Integer;
    function StartTransaction: ITransaction;
    function GetLastInsertedIdentityScoped: Int64;

    function InternalConnect: TFDConnection;
  public
    destructor Destroy; override;
  end;

implementation

uses System.Classes, System.SysUtils, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Stan.Async, FireDAC.Phys.MySQL;

function GetFDCustomTransaction(const aTransaction: ITransaction): TFDCustomTransaction;
begin
  Result := nil;
  if not Assigned(aTransaction) then
    Exit;

  if not (aTransaction is TMySqlTransaction) then
  begin
    raise EArgumentException.Create('Parameter aTransaction must be of class TMySqlTransaction.');
  end;

  Result := (aTransaction as TMySqlTransaction).fTransaction;
end;

{ TMySqlConnection }

destructor TMySqlConnection.Destroy;
begin
  fConnection.Free;
  fParameters.Free;
  inherited;
end;

function TMySqlConnection.Connect: Boolean;
begin
  Result := InternalConnect.Connected;
end;

function TMySqlConnection.CreatePreparedCommand(const aSqlCommand: string): ISqlPreparedCommand;
begin
  var lCommand := TFDCommand.Create(nil);
  lCommand.Connection := InternalConnect;
  lCommand.ResourceOptions.ParamCreate := True;
  lCommand.CommandText.Text := aSqlCommand;
  Result := TMySqlPreparedCommand.Create(lCommand);
end;

function TMySqlConnection.CreatePreparedQuery(const aSqlCommand: string): ISqlPreparedQuery;
begin
  var lQuery := TFDQuery.Create(nil);
  lQuery.Connection := InternalConnect;
  lQuery.ResourceOptions.ParamCreate := True;
  lQuery.SQL.Text := aSqlCommand;
  Result := TMySqlPreparedQuery.Create(lQuery);
end;

function TMySqlConnection.ExecuteCommand(const aSqlCommand: string; const aTransaction: ITransaction): Integer;
begin
  var lCommand := TFDCommand.Create(nil);
  try
    lCommand.Connection := InternalConnect;
    lCommand.Transaction := GetFDCustomTransaction(aTransaction);
    Result := lCommand.Execute(aSqlCommand);
  finally
    lCommand.Free;
  end;
end;

function TMySqlConnection.GetSelectResult(const aSqlSelect: string; const aTransaction: ITransaction): ISqlResult;
begin
  var lQuery := TFDQuery.Create(nil);
  try
    lQuery.Connection := InternalConnect;
    lQuery.Transaction := GetFDCustomTransaction(aTransaction);
    lQuery.Open(aSqlSelect);
    Result := TMySqlResult.Create(lQuery, True); // TMySqlResult takes ownerrship of lQuery.
  except;
    lQuery.Free;
    raise;
  end;
end;

function TMySqlConnection.GetLastInsertedIdentityScoped: Int64;
begin
  Result := -1;
  var lSqlResult := GetSelectResult('select LAST_INSERT_ID()');
  if lSqlResult.Next then
    Result := lSqlResult.Fields[0].AsLargeInt;
end;

function TMySqlConnection.GetParameters: TSqlConnectionParametersBase;
begin
  if not Assigned(fParameters) then
    fParameters := TMySqlConnectionParameters.Create;
  Result := fParameters;
end;

function TMySqlConnection.StartTransaction: ITransaction;
begin
  var lTransaction := TFDTransaction.Create(nil);
  try
    lTransaction.Connection := InternalConnect;
    lTransaction.StartTransaction;
    Result := TMySqlTransaction.Create(lTransaction); // TMySqlTransaction takes ownerrship of lTransaction.
  except;
    lTransaction.Free;
    raise;
  end;
end;

{ TMySqlResult }

constructor TMySqlResult.Create(const aQuery: TFDCustomQuery; const aOwnsQuery: Boolean);
begin
  inherited Create;
  fQuery := aQuery;
  fOwnsQuery := aOwnsQuery;
end;

destructor TMySqlResult.Destroy;
begin
  if fOwnsQuery then
    fQuery.Free;
  inherited;
end;

procedure TMySqlResult.ConfigureDatasource(const aDataSource: TDataSource);
begin
  aDataSource.DataSet := fQuery;
end;

function TMySqlResult.FieldByIndex(const aIndex: Integer): TField;
begin
  Result := fQuery.Fields[aIndex];
end;

function TMySqlResult.FieldByName(const aName: string): TField;
begin
  Result := fQuery.FieldByName(aName);
end;

function TMySqlResult.FieldDefByIndex(const aIndex: Integer): TFieldDef;
begin
  Result := fQuery.FieldDefs[aIndex];
end;

function TMySqlResult.GetFieldCount: Integer;
begin
  Result := fQuery.Fields.Count;
end;

function TMySqlResult.Next: Boolean;
begin
  if fCursorStarted then
    fQuery.Next;
  Result := not fQuery.Eof;
  fCursorStarted := True;
end;

function TMySqlConnection.InternalConnect: TFDConnection;
begin
  if not Assigned(fConnection) then
  begin
    fConnection := TFDConnection.Create(nil);
    fConnection.Params.Text := GetParameters.GetConnectionString;
  end;
  fConnection.Connected := True;
  Result := fConnection;
end;

{ TMySqlTransaction }

constructor TMySqlTransaction.Create(const aTransaction: TFDCustomTransaction);
begin
  inherited Create;
  fTransaction := aTransaction;
end;

destructor TMySqlTransaction.Destroy;
begin
  if GetActive then
    Rollback;
  fTransaction.Free;
  inherited;
end;

function TMySqlTransaction.GetActive: Boolean;
begin
  Result := Assigned(fTransaction) and fTransaction.Active;
end;

function TMySqlTransaction.GetWasCommitted: Boolean;
begin
  Result := fWasCommitted;
end;

function TMySqlTransaction.GetWasRollbacked: Boolean;
begin
  Result := fWasRollbacked;
end;

function TMySqlTransaction.Commit: Boolean;
begin
  Result := False;
  if GetActive then
  begin
    fTransaction.Commit;
    fWasCommitted := True;
    Result := True;
  end;
  FreeAndNil(fTransaction);
end;

function TMySqlTransaction.Rollback: Boolean;
begin
  Result := False;
  if GetActive then
  begin
    fTransaction.Rollback;
    fWasRollbacked := True;
    Result := True;
  end;
  FreeAndNil(fTransaction);
end;

{ TMySqlConnectionParameters }

function TMySqlConnectionParameters.GetConnectionString: string;
begin
  Result := 'DriverID=MySQL' + sLineBreak +
    'Server=' + Host + sLineBreak +
    'Port=' + IntToStr(Port) + sLineBreak +
    'Database=' + Databasename + sLineBreak +
    'User_Name=' + Username + sLineBreak +
    'Password=' + Password;
end;

{ TMySqlPreparedCommand }

constructor TMySqlPreparedCommand.Create(const aCommand: TFDCommand);
begin
  inherited Create;
  fCommand := aCommand;
end;

destructor TMySqlPreparedCommand.Destroy;
begin
  fCommand.Free;
  inherited;
end;

function TMySqlPreparedCommand.Execute(const aTransaction: ITransaction): Integer;
begin
  fCommand.Transaction := GetFDCustomTransaction(aTransaction);
  fCommand.Execute;
  Result := fCommand.RowsAffected;
end;

function TMySqlPreparedCommand.GetParamCount: Integer;
begin
  Result := fCommand.Params.Count;
end;

function TMySqlPreparedCommand.ParamByIndex(const aIndex: Integer): ISqlParameter;
begin
  Result := TMySqlParameter.Create(fCommand.Params[aIndex]);
end;

function TMySqlPreparedCommand.ParamByName(const aName: string): ISqlParameter;
begin
  Result := TMySqlParameter.Create(fCommand.ParamByName(aName));
end;

procedure TMySqlPreparedCommand.Prepare;
begin
  fCommand.Prepare;
end;

{ TMySqlPreparedQuery }

constructor TMySqlPreparedQuery.Create(const aQuery: TFDCustomQuery);
begin
  inherited Create;
  fQuery := aQuery;
end;

destructor TMySqlPreparedQuery.Destroy;
begin
  fQuery.Free;
  inherited;
end;

function TMySqlPreparedQuery.GetParamCount: Integer;
begin
  Result := fQuery.ParamCount;
end;

function TMySqlPreparedQuery.Open(const aTransaction: ITransaction): ISqlResult;
begin
  fQuery.Transaction := GetFDCustomTransaction(aTransaction);
  fQuery.Open('');
  Result := TMySqlResult.Create(fQuery, False);
end;

function TMySqlPreparedQuery.ParamByIndex(const aIndex: Integer): ISqlParameter;
begin
  Result := TMySqlParameter.Create(fQuery.Params[aIndex]);
end;

function TMySqlPreparedQuery.ParamByName(const aName: string): ISqlParameter;
begin
  Result := TMySqlParameter.Create(fQuery.ParamByName(aName));
end;

procedure TMySqlPreparedQuery.Prepare;
begin
  fQuery.Prepare;
end;

{ TMySqlParameter }

constructor TMySqlParameter.Create(const aParameter: TFDParam);
begin
  inherited Create;
  fParameter := aParameter;
end;

function TMySqlParameter.GetDataType: TFieldType;
begin
  Result := fParameter.DataType;
end;

function TMySqlParameter.GetName: string;
begin
  Result := fParameter.Name;
end;

function TMySqlParameter.GetValue: Variant;
begin
  Result := fParameter.Value;
end;

procedure TMySqlParameter.SetDataType(const aValue: TFieldType);
begin
  fParameter.DataType := aValue;
end;

procedure TMySqlParameter.SetValue(const aValue: Variant);
begin
  fParameter.Value := aValue;
end;

end.
