unit ConnectionFactory;

interface

uses SqlConnection;

type
  TConnectionFactory = class
  strict private
    class procedure ApplyConfig(const aConnection: ISqlConnection);
  public
    class function CreateConnection: ISqlConnection;
  end;

implementation

uses System.SysUtils, ConfigReader, MySqlConnection, SshTunnelSqlConnection;

{ TConnectionFactory }

class function TConnectionFactory.CreateConnection: ISqlConnection;
begin
  var lSqlConnection: ISqlConnection := TMySqlConnection.Create;
  ApplyConfig(lSqlConnection);
  if Length(TConfigReader.Instance.Connection.SshServerHost) > 0 then
  begin
    var lSshConnection: ISqlConnection := TSshTunnelSqlConnection.Create(lSqlConnection,
      TConfigReader.Instance.Connection.SshServerHost,
      TConfigReader.Instance.Connection.SshServerPort,
      TConfigReader.Instance.Connection.SshLocalTunnelPort
    );
    Result := lSshConnection;
  end
  else
  begin
    Result := lSqlConnection;
  end;
end;

class procedure TConnectionFactory.ApplyConfig(const aConnection: ISqlConnection);
begin
  if not TConfigReader.Instance.Found then
    raise Exception.Create('Connection parameter not found.');

  aConnection.Parameters.Host := TConfigReader.Instance.Connection.DatabaseHost;
  aConnection.Parameters.Port := TConfigReader.Instance.Connection.DatabasePort;
  aConnection.Parameters.Databasename := TConfigReader.Instance.Connection.DatabaseName;
  aConnection.Parameters.Username := TConfigReader.Instance.Connection.DatabaseUserName;
  aConnection.Parameters.Password := TConfigReader.Instance.Connection.DatabaseUserPassword;
end;

end.
