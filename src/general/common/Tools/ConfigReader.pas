unit ConfigReader;

interface

uses System.Classes, System.Generics.Collections;

type
  TConfigConnection = record
    ConnnectionName: string;
    DatabaseHost: string;
    DatabasePort: Integer;
    DatabaseUserName: string;
    DatabaseUserPassword: string;
    DatabaseName: string;
    SshServerHost: string;
    SshServerPort: Integer;
    SshLocalTunnelPort: Integer;
    ShapeVisible: Boolean;
    ShapeColor: string;
  end;

  TConfigReader = class
  strict private
    class var fInstance: TConfigReader;

    var
    fConnectionNames: TStrings;
    fConnections: TList<TConfigConnection>;
    fCurrentConnectionIndex: Integer;
    fFound: Boolean;
    procedure ReadFile;
    function GetConnection: TConfigConnection;
    function GetFound: Boolean;
    function GetIniFilePath: string;
    procedure WriteExampleEntries;

    class function GetInstance: TConfigReader; static;
  private
    function GetConnectionNames: TStrings;
  public
    class destructor ClassDestroy;
    class property Instance: TConfigReader read GetInstance;

    constructor Create;
    destructor Destroy; override;
    procedure SelectConnection(const aConnectionIndex: Integer);
    property Found: Boolean read GetFound;
    property ConnectionNames: TStrings read GetConnectionNames;
    property Connection: TConfigConnection read GetConnection;
  end;

implementation

uses System.SysUtils, System.IniFiles, System.IOUtils;

{ TConfigReader }

class destructor TConfigReader.ClassDestroy;
begin
  fInstance.Free;
end;

constructor TConfigReader.Create;
begin
  inherited Create;
  fConnectionNames := TStringList.Create;
  fConnections := TList<TConfigConnection>.Create;
end;

destructor TConfigReader.Destroy;
begin
  fConnections.Free;
  fConnectionNames.Free;
  inherited;
end;

function TConfigReader.GetConnection: TConfigConnection;
begin
  ReadFile;
  if not fFound then
    Exit(default(TConfigConnection));

  if fConnections.Count > 1 then
  begin
    if (0 <= fCurrentConnectionIndex) and (fCurrentConnectionIndex < fConnections.Count)  then
      Exit(fConnections[fCurrentConnectionIndex]);
  end;
  Result := fConnections.First;
end;

function TConfigReader.GetConnectionNames: TStrings;
begin
  ReadFile;
  Result := fConnectionNames;
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

  var lIniPath := GetIniFilePath;
  if TFile.Exists(lIniPath) then
  begin
    var lIniFile := TIniFile.Create(lIniPath);
    try
      fConnections.Clear;
      var lSections := TStringList.Create;
      try
        lIniFile.ReadSections(lSections);
        const ConnectionString = 'Connection';
        for var lSection in lSections do
        begin
          if not lSection.StartsWith(ConnectionString) then
            Continue;

          var lConnection := default(TConfigConnection);
          lConnection.DatabaseHost := lIniFile.ReadString(lSection, 'DatabaseHost', 'localhost');
          lConnection.DatabasePort := lIniFile.ReadInteger(lSection, 'DatabasePort', 0);
          lConnection.DatabaseUserName := lIniFile.ReadString(lSection, 'DatabaseUserName', '');
          lConnection.DatabaseUserPassword := lIniFile.ReadString(lSection, 'DatabaseUserPassword', '');
          lConnection.DatabaseName := lIniFile.ReadString(lSection, 'DatabaseName', '');
          lConnection.SshServerHost := lIniFile.ReadString(lSection, 'SshServerHost', '');
          lConnection.SshServerPort := lIniFile.ReadInteger(lSection, 'SshServerPort', 0);
          lConnection.SshLocalTunnelPort := lIniFile.ReadInteger(lSection, 'SshLocalTunnelPort', 0);
          lConnection.ShapeVisible := lIniFile.ValueExists(lSection, 'ShapeColor');
          lConnection.ShapeColor := lIniFile.ReadString(lSection, 'ShapeColor', '');

          var lConnectionName := lSection;
          Delete(lConnectionName, 1, Length(ConnectionString));
          lConnectionName := Trim(lConnectionName);
          if Length(lConnectionName) = 0 then
            lConnectionName := lSection;

          lConnection.ConnnectionName := lConnectionName;
          fConnectionNames.Add(lConnectionName);
          fConnections.Add(lConnection);
          fFound := True;
        end;
      finally
        lSections.Free;
      end;
    finally
      lIniFile.Free;
    end;
  end
  else
  begin
    WriteExampleEntries;
  end;
end;

procedure TConfigReader.SelectConnection(const aConnectionIndex: Integer);
begin
  ReadFile;
  fCurrentConnectionIndex := aConnectionIndex;
end;

procedure TConfigReader.WriteExampleEntries;
begin
  var lIniPath := GetIniFilePath;
  ForceDirectories(ExtractFilePath(lIniPath));
  var lIniFile := TIniFile.Create(lIniPath);
  try
    // Write example entries.
    lIniFile.WriteString('Connection', 'DatabaseHost', 'localhost');
    lIniFile.WriteInteger('Connection', 'DatabasePort', 0);
    lIniFile.WriteString('Connection', 'DatabaseUserName', '');
    lIniFile.WriteString('Connection', 'DatabaseUserPassword', '');
    lIniFile.WriteString('Connection', 'DatabaseName', '');
    lIniFile.WriteString('Connection', 'SshServerHost', '');
    lIniFile.WriteInteger('Connection', 'SshServerPort', 0);
    lIniFile.WriteInteger('Connection', 'SshLocalTunnelPort', 0);
    lIniFile.WriteString('Connection', 'ShapeColor', '0000ff');
  finally
    lIniFile.Free;
  end;
end;

function TConfigReader.GetIniFilePath: string;
begin
  var lExeName := TPath.GetFileNameWithoutExtension(ParamStr(0));
  var lIniDir := TPath.Combine(TPath.GetCachePath, TPath.Combine('BBE', lExeName));
  Result := TPath.Combine(lIniDir, lExeName + '.ini');
end;

end.
