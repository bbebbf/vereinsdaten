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

  TLoggingTargetConfig = class
  strict private
    fTargetType: string;
    fParams: TDictionary<string, string>;
  public
    constructor Create(const aTargetType: string);
    destructor Destroy; override;
    property TargetType: string read fTargetType;
    property Params: TDictionary<string, string> read fParams;
  end;

  TConfigReader = class
  strict private
    class var fInstance: TConfigReader;

    var
    fConnectionNames: TStrings;
    fConnections: TList<TConfigConnection>;
    fCurrentConnectionIndex: Integer;
    fLogLevel: string;
    fLoggingTargets: TList<TLoggingTargetConfig>;
    fFound: Boolean;
    procedure ReadFile;
    function GetConnection: TConfigConnection;
    function GetFound: Boolean;
    function GetConfigDir: string;
    function GetIniFilePath: string;
    procedure WriteExampleEntries;

    class function GetInstance: TConfigReader; static;
    function GetConnectionNames: TStrings;
    function GetLoggingTargets: TList<TLoggingTargetConfig>;
    function GetLogLevel: string;
  public
    class destructor ClassDestroy;
    class property Instance: TConfigReader read GetInstance;

    constructor Create;
    destructor Destroy; override;
    procedure SelectConnection(const aConnectionIndex: Integer);
    property Found: Boolean read GetFound;
    property ConnectionNames: TStrings read GetConnectionNames;
    property Connection: TConfigConnection read GetConnection;
    property ConfigDir: string read GetConfigDir;
    property LogLevel: string read GetLogLevel;
    property LoggingTargets: TList<TLoggingTargetConfig> read GetLoggingTargets;
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
  fLoggingTargets := TList<TLoggingTargetConfig>.Create;
end;

destructor TConfigReader.Destroy;
begin
  fLoggingTargets.Free;
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

function TConfigReader.GetLoggingTargets: TList<TLoggingTargetConfig>;
begin
  ReadFile;
  Result := fLoggingTargets;
end;

function TConfigReader.GetLogLevel: string;
begin
  ReadFile;
  Result := fLogLevel;
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
        const Logging = 'Logging';
        for var lSection in lSections do
        begin
          if lSection.StartsWith(ConnectionString) then
          begin
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
          end
          else if lSection = Logging then
          begin
            fLogLevel := lIniFile.ReadString(lSection, 'Level', '');
            var lSubSections := TStringList.Create;
            try
              lIniFile.ReadSubSections(lSection, lSubSections);
              for var lSubSection in lSubSections do
              begin
                var lLoggingTarget := TLoggingTargetConfig.Create(lSubSection);
                fLoggingTargets.Add(lLoggingTarget);
                var lSectionValues := TStringList.Create;
                try
                  lIniFile.ReadSectionValues(lSection + '.' + lSubSection, lSectionValues);
                  for var lValue in lSectionValues do
                  begin
                    var lParts := lValue.Split(['=']);
                    if Length(lParts) = 2 then
                      lLoggingTarget.Params.Add(lParts[0], lParts[1]);
                  end;
                finally
                  lSectionValues.Free;
                end;
              end;
            finally
              lSubSections.Free;
            end;
          end;
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
  var lIniDir := GetConfigDir;
  var lExeName := TPath.GetFileNameWithoutExtension(ParamStr(0));
  Result := TPath.Combine(lIniDir, lExeName + '.ini');
end;

function TConfigReader.GetConfigDir: string;
begin
  var lExeName := TPath.GetFileNameWithoutExtension(ParamStr(0));
  Result := TPath.Combine(TPath.GetCachePath, TPath.Combine('BBE', lExeName));
end;

{ TLoggingTargetConfig }

constructor TLoggingTargetConfig.Create(const aTargetType: string);
begin
  inherited Create;
  fParams := TDictionary<string, string>.Create;
  fTargetType := aTargetType;
end;

destructor TLoggingTargetConfig.Destroy;
begin
  fParams.Free;
  inherited;
end;

end.
