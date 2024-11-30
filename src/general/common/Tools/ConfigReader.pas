unit ConfigReader;

interface

type
  TConfigConnection = record
    Host: string;
    Port: Integer;
    Databasename: string;
    Username: string;
    Password: string;
    SshRemoteHost: string;
    SshRemotePort: Integer;
  end;

  TConfigReader = class(TNoRefCountObject)
  strict private
    class var fInstance: TConfigReader;

    var
    fConnection: TConfigConnection;
    fFound: Boolean;
    procedure ReadFile;
    function GetConnection: TConfigConnection;
    function GetFound: Boolean;

    class function GetInstance: TConfigReader; static;
  public
    class destructor ClassDestroy;
    class property Instance: TConfigReader read GetInstance;

    property Found: Boolean read GetFound;
    property Connection: TConfigConnection read GetConnection;
  end;

implementation

uses System.SysUtils, System.IniFiles, System.IOUtils, Vcl.Forms;

{ TConfigReader }

class destructor TConfigReader.ClassDestroy;
begin
  fInstance.Free;
end;

function TConfigReader.GetConnection: TConfigConnection;
begin
  ReadFile;
  Result := fConnection;
end;

function TConfigReader.GetFound: Boolean;
begin
  ReadFile;
  Result := fFound;
end;

class function TConfigReader.GetInstance: TConfigReader;
begin
  if not Assigned(fInstance) then
    fInstance := TConfigReader.Create;
  Result := fInstance;
end;

procedure TConfigReader.ReadFile;
begin
  if fFound then
    Exit;

  var lExeName := TPath.GetFileNameWithoutExtension(Application.ExeName);
  var lIniDir := TPath.Combine(TPath.GetCachePath, TPath.Combine('BBE', lExeName));
  var lIniPath := TPath.Combine(lIniDir, lExeName + '.ini');
  if TFile.Exists(lIniPath) then
  begin
    var lIniFile := TIniFile.Create(lIniPath);
    try
      // Read entries.
      fConnection.Host := lIniFile.ReadString('Connection', 'Host', 'localhost');
      fConnection.Port := lIniFile.ReadInteger('Connection', 'Port', 0);
      fConnection.Databasename := lIniFile.ReadString('Connection', 'Databasename', '');
      fConnection.Username := lIniFile.ReadString('Connection', 'Username', '');
      fConnection.Password := lIniFile.ReadString('Connection', 'Password', '');
      fConnection.SshRemoteHost := lIniFile.ReadString('Connection', 'SshRemoteHost', '');
      fConnection.SshRemotePort := lIniFile.ReadInteger('Connection', 'SshRemotePort', 0);
      fFound := True;
    finally
      lIniFile.Free;
    end;
  end
  else
  begin
    ForceDirectories(lIniDir);
    var lIniFile := TIniFile.Create(lIniPath);
    try
      // Write example entries.
      lIniFile.WriteString('Connection', 'Host', 'localhost');
      lIniFile.WriteInteger('Connection', 'Port', 0);
      lIniFile.WriteString('Connection', 'Databasename', '');
      lIniFile.WriteString('Connection', 'Username', '');
      lIniFile.WriteString('Connection', 'Password', '');
      lIniFile.WriteString('Connection', 'SshRemoteHost', '');
      lIniFile.WriteInteger('Connection', 'SshRemotePort', 0);
    finally
      lIniFile.Free;
    end;
  end;

end;

end.
