unit Logging.Intf;

interface

uses Winapi.Windows, System.Generics.Collections;

type
  TLogLevel = (Error, Warning, Info, Debug);

  TLoggingData = record
    TimestampUTC: TDateTime;
    LogLevel: TLogLevel;
    LogMessage: string;
    ProcessId: DWORD;
    function LogLevelToColoredText: string;
    function ToString(const aColoredConsoleText: Boolean = False): string;
    function ToColoredConsoleText: string;
  end;

  ILoggingTarget = interface
    ['{3D5A5D8A-2DC7-49C9-9682-E446E2CFD42F}']
    function ConfigurationInfo: string;
    procedure InitializeTarget;
    procedure WriteLoggingData(const aLoggingData: TLoggingData);
  end;

  ILogger = interface
    ['{034CF09A-9A49-4789-BDC7-9A37E5812909}']
    procedure SetLogLevel(const aLogLevel: TLogLevel);
    function GetLogLevel: TLogLevel;
    function GetTargets: TList<ILoggingTarget>;
    function GetTargetConfigInfos: string;
    procedure Error(const aText: string);
    procedure Warning(const aText: string);
    procedure Info(const aText: string);
    procedure Debug(const aText: string);
    property LogLevel: TLogLevel read GetLogLevel write SetLogLevel;
    property TargetConfigInfos: string read GetTargetConfigInfos;
    property Targets: TList<ILoggingTarget> read GetTargets;
  end;

  TLogger = class
  strict private
    class var fInstance: ILogger;
    class function GetInstance: ILogger; static;
    class procedure SetLogLevel(const aLogLevel: TLogLevel); static;
    class function GetLogLevel: TLogLevel; static;
    class function GetTargets: TList<ILoggingTarget>; static;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function LogLevelToStr(const aLogLevel: TLogLevel): string;
    class function TargetConfigInfos: string;
    class procedure Error(const aText: string);
    class procedure Warning(const aText: string);
    class procedure Info(const aText: string);
    class procedure Debug(const aText: string);
    class property LogLevel: TLogLevel read GetLogLevel write SetLogLevel;
    class property Targets: TList<ILoggingTarget> read GetTargets;
  end;

implementation

uses System.SysUtils, System.DateUtils, Logging.Impl, Logging.TargetFile;

{ TLogger }

class constructor TLogger.ClassCreate;
begin
  fInstance := nil;
end;

class destructor TLogger.ClassDestroy;
begin
  fInstance := nil;
end;

class procedure TLogger.Error(const aText: string);
begin
  GetInstance.Error(aText);
end;

class procedure TLogger.Warning(const aText: string);
begin
  GetInstance.Warning(aText);
end;

class procedure TLogger.Info(const aText: string);
begin
  GetInstance.Info(aText);
end;

class procedure TLogger.Debug(const aText: string);
begin
  GetInstance.Debug(aText);
end;

class function TLogger.GetLogLevel: TLogLevel;
begin
  Result := GetInstance.LogLevel;
end;

class function TLogger.GetTargets: TList<ILoggingTarget>;
begin
  Result := GetInstance.Targets;
end;

class procedure TLogger.SetLogLevel(const aLogLevel: TLogLevel);
begin
  GetInstance.LogLevel := aLogLevel;
end;

class function TLogger.TargetConfigInfos: string;
begin
  Result := GetInstance.TargetConfigInfos;
end;

class function TLogger.GetInstance: ILogger;
begin
  if not Assigned(fInstance) then
  begin
    fInstance := TLoggingImpl.Create;
    fInstance.LogLevel := TLogLevel.Error;
  end;
  Result := fInstance;
end;

class function TLogger.LogLevelToStr(const aLogLevel: TLogLevel): string;
begin
  case aLogLevel of
    TLogLevel.Error:
      Exit('Error');
    TLogLevel.Warning:
      Exit('Warning');
    TLogLevel.Info:
      Exit('Info');
    TLogLevel.Debug:
      Exit('Debug');
    else
      Exit('???');
  end;
end;

{ TLoggingData }

function TLoggingData.ToString(const aColoredConsoleText: Boolean): string;
begin
  var lLogLevelText := '';
  if aColoredConsoleText then
    lLogLevelText := LogLevelToColoredText
  else
    lLogLevelText := TLogger.LogLevelToStr(LogLevel);

  Result := '[' + UIntToStr(ProcessId) + '][' + DateToISO8601(TimestampUTC) + '][' +
    lLogLevelText + '][' + LogMessage;
end;

function TLoggingData.ToColoredConsoleText: string;
begin
  Result := ToString(True);
end;

function TLoggingData.LogLevelToColoredText: string;
begin
  var lTextColor: string := '0';
  case LogLevel of
    TLogLevel.Error: lTextColor := '91'; // red
    TLogLevel.Warning: lTextColor := '93'; // yellow
    TLogLevel.Info: lTextColor := '96'; // cyan
    TLogLevel.Debug: lTextColor := '97'; // white
  end;
  Result := #27 + '[' + lTextColor + 'm' + TLogger.LogLevelToStr(LogLevel) + #27 + '[0m';
end;

end.
