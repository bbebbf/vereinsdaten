unit MySqlConnection;

{$I \inc\CompilerDirectives.inc }

interface

uses
  System.SysUtils, Data.DB, SqlConnection, Transaction,
  FireDAC.Comp.Client, FireDAC.Stan.Param;

type
  TMySqlResult = class(TInterfacedObject, ISqlResult)
  strict private
    fQuery: TFDCustomQuery;
    fOwnsQuery: Boolean;
    fCursorStarted: Boolean;
    function GetFieldCount: Integer;
    function Next: Boolean;
    function FieldByName(const aName: string): TField;
    function FieldByIndex(const aIndex: Integer): TField;
    function FieldDefByIndex(const aIndex: Integer): TFieldDef;
  public
    constructor Create(const aQuery: TFDCustomQuery; const aOwnsQuery: Boolean);
    destructor Destroy; override;
  end;

  TMySqlTransaction = class(TInterfacedObject, ITransaction)
  private
    fTransaction: TFDCustomTransaction;
  strict private
    procedure Commit;
    procedure Rollback;
  public
    constructor Create(const aTransaction: TFDCustomTransaction);
    destructor Destroy; override;
  end;

  TMySqlParameter = class(TInterfacedObject, ISqlParameter)
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

  TMySqlPreparedCommand = class(TInterfacedObject, ISqlPreparedCommand)
  strict private
    fCommand: TFDCommand;
    procedure Prepare;
    function GetParamCount: Integer;
    function ParamByName(const aName: string): ISqlParameter;
    function ParamByIndex(const aIndex: Integer): ISqlParameter;
    function Execute: Integer;
  public
    constructor Create(const aCommand: TFDCommand);
    destructor Destroy; override;
  end;

  TMySqlPreparedQuery = class(TInterfacedObject, ISqlPreparedQuery)
  strict private
    fQuery: TFDCustomQuery;
    procedure Prepare;
    function GetParamCount: Integer;
    function ParamByName(const aName: string): ISqlParameter;
    function ParamByIndex(const aIndex: Integer): ISqlParameter;
    function Open: ISqlResult;
  public
    constructor Create(const aQuery: TFDCustomQuery);
    destructor Destroy; override;
  end;

  TMySqlConnectionParameters = class(TSqlConnectionParametersBase)
  public
    function GetConnectionString: string; override;
  end;

  TMySqlConnection = class(TInterfacedObject, ISqlConnection)
  strict private
    fParameters: TSqlConnectionParametersBase;
    fConnection: TFDConnection;
    function GetParameters: TSqlConnectionParametersBase;
    function Connect: Boolean;
    function CreatePreparedCommand(const aSqlCommand: string; const aTransaction: ITransaction = nil): ISqlPreparedCommand;
    function CreatePreparedQuery(const aSqlCommand: string; const aTransaction: ITransaction = nil): ISqlPreparedQuery;
    function GetSelectResult(const aSqlSelect: string;
      const aTransaction: ITransaction = nil): ISqlResult;
    function ExecuteCommand(const aSqlCommand: string;
      const aTransaction: ITransaction = nil): Integer;
    function StartTransaction: ITransaction;
    function GetLastInsertedIdentityScoped: Int64;

    function InternalConnect: TFDConnection;
    function InternalGetTransaction(const aTransaction: ITransaction): TFDCustomTransaction;
  public
    destructor Destroy; override;
  end;

implementation

uses System.Classes, FireDAC.Stan.Def, FireDAC.DApt, FireDAC.Stan.Async, FireDAC.Phys.MySQL;

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

function TMySqlConnection.CreatePreparedCommand(const aSqlCommand: string; const aTransaction: ITransaction): ISqlPreparedCommand;
begin
  var lCommand := TFDCommand.Create(nil);
  lCommand.Connection := InternalConnect;
  lCommand.Transaction := InternalGetTransaction(aTransaction);
  lCommand.ResourceOptions.ParamCreate := True;
  lCommand.CommandText.Text := aSqlCommand;
  Result := TMySqlPreparedCommand.Create(lCommand);
end;

function TMySqlConnection.CreatePreparedQuery(const aSqlCommand: string; const aTransaction: ITransaction): ISqlPreparedQuery;
begin
  var lQuery := TFDQuery.Create(nil);
  lQuery.Connection := InternalConnect;
  lQuery.Transaction := InternalGetTransaction(aTransaction);
  lQuery.ResourceOptions.ParamCreate := True;
  lQuery.SQL.Text := aSqlCommand;
  Result := TMySqlPreparedQuery.Create(lQuery);
end;

function TMySqlConnection.ExecuteCommand(const aSqlCommand: string; const aTransaction: ITransaction): Integer;
begin
  var lCommand := TFDCommand.Create(nil);
  try
    lCommand.Connection := InternalConnect;
    lCommand.Transaction := InternalGetTransaction(aTransaction);
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
    lQuery.Transaction := InternalGetTransaction(aTransaction);
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

function TMySqlConnection.InternalGetTransaction(
  const aTransaction: ITransaction): TFDCustomTransaction;
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

{ TMySqlTransaction }

constructor TMySqlTransaction.Create(const aTransaction: TFDCustomTransaction);
begin
  inherited Create;
  fTransaction := aTransaction;
end;

destructor TMySqlTransaction.Destroy;
begin
  if fTransaction.Active then
    Rollback;
  inherited;
end;

procedure TMySqlTransaction.Commit;
begin
  if fTransaction.Active then
    fTransaction.Commit;
end;

procedure TMySqlTransaction.Rollback;
begin
  if fTransaction.Active then
    fTransaction.Rollback;
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

function TMySqlPreparedCommand.Execute: Integer;
begin
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

function TMySqlPreparedQuery.Open: ISqlResult;
begin
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
