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
  if Length(TConfigReader.Instance.Connection.SshRemoteHost) > 0 then
  begin
    var lSshConnection: ISqlConnection := TSshTunnelSqlConnection.Create(lSqlConnection,
      TConfigReader.Instance.Connection.SshRemoteHost,
      TConfigReader.Instance.Connection.SshRemotePort
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

  aConnection.Parameters.Host := TConfigReader.Instance.Connection.Host;
  aConnection.Parameters.Port := TConfigReader.Instance.Connection.Port;
  aConnection.Parameters.Databasename := TConfigReader.Instance.Connection.Databasename;
  aConnection.Parameters.Username := TConfigReader.Instance.Connection.Username;
  aConnection.Parameters.Password := TConfigReader.Instance.Connection.Password;
end;

end.
