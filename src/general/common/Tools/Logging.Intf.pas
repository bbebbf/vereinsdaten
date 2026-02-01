unit Logging.Intf;

interface

uses System.Generics.Collections;

type
  TLogLevel = (Error, Warning, Info, Debug);

  ILoggingTarget = interface
    ['{3D5A5D8A-2DC7-49C9-9682-E446E2CFD42F}']
    function ConfigurationInfo: string;
    procedure WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);
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

uses Logging.Impl, Logging.TargetFile;

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

end.
