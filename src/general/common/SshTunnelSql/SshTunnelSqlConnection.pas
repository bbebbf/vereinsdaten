unit SshTunnelSqlConnection;

interface

uses
  InterfacedBase, Data.DB, SqlConnection, Transaction, SshTunnel;

type
  TSshTunnelSqlConnection = class(TInterfacedBase, ISqlConnection)
  strict private
    fSqlConnection: ISqlConnection;
    fSshTunnel: ISshTunnel;
    fRemoteHost: string;
    fRemotePort: Integer;
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
  public
    constructor Create(const aSqlConnection: ISqlConnection; const aRemoteHost: string; const aRemotePort: Integer);
    destructor Destroy; override;
  end;


implementation

{ TSshTunnelSqlConnection }

constructor TSshTunnelSqlConnection.Create(const aSqlConnection: ISqlConnection; const aRemoteHost: string; const aRemotePort: Integer);
begin
  inherited Create;
  fSqlConnection := aSqlConnection;
  fRemoteHost := aRemoteHost;
  fRemotePort := aRemotePort;
end;

destructor TSshTunnelSqlConnection.Destroy;
begin
  fSqlConnection := nil;
  if Assigned(fSshTunnel) then
  begin
    fSshTunnel.Disconnect;
    fSshTunnel := nil;
  end;
  inherited;
end;

function TSshTunnelSqlConnection.Connect: Boolean;
begin
  if not Assigned(fSshTunnel) then
  begin
    fSshTunnel := CreateSshTunnelProcess(fRemoteHost, fRemotePort, GetParameters.Port);
    if not fSshTunnel.Connect then
      Exit(True);
  end;
  Result := fSqlConnection.Connect;
end;

function TSshTunnelSqlConnection.CreatePreparedCommand(const aSqlCommand: string;
  const aTransaction: ITransaction): ISqlPreparedCommand;
begin
  Result := fSqlConnection.CreatePreparedCommand(aSqlCommand, aTransaction);
end;

function TSshTunnelSqlConnection.CreatePreparedQuery(const aSqlCommand: string;
  const aTransaction: ITransaction): ISqlPreparedQuery;
begin
  Result := fSqlConnection.CreatePreparedQuery(aSqlCommand, aTransaction);
end;

function TSshTunnelSqlConnection.ExecuteCommand(const aSqlCommand: string; const aTransaction: ITransaction): Integer;
begin
  Result := fSqlConnection.ExecuteCommand(aSqlCommand, aTransaction);
end;

function TSshTunnelSqlConnection.GetLastInsertedIdentityScoped: Int64;
begin
  Result := fSqlConnection.GetLastInsertedIdentityScoped;
end;

function TSshTunnelSqlConnection.GetParameters: TSqlConnectionParametersBase;
begin
  Result := fSqlConnection.GetParameters;
end;

function TSshTunnelSqlConnection.GetSelectResult(const aSqlSelect: string; const aTransaction: ITransaction): ISqlResult;
begin
  Result := fSqlConnection.GetSelectResult(aSqlSelect, aTransaction);
end;

function TSshTunnelSqlConnection.StartTransaction: ITransaction;
begin
  Result := fSqlConnection.StartTransaction;
end;

end.
