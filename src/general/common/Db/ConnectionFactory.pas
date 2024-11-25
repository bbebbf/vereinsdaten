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

uses System.SysUtils, ConfigReader, MySqlConnection;

{ TConnectionFactory }

class function TConnectionFactory.CreateConnection: ISqlConnection;
begin
  Result := TMySqlConnection.Create;
  ApplyConfig(Result);
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
