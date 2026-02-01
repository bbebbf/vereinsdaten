unit Vdm.Logging;

interface

uses Logging.Intf;

type
  TVdmLogging = class
  strict private
    class function StrToLogLevel(const aLogLevelStr: string): TLogLevel;
  public
    class procedure ApplyLoggingConfig;
  end;

implementation

uses System.IOUtils, ConfigReader, Logging.TargetFile, Logging.TargetPipe;

{ TVdmLogging }

class procedure TVdmLogging.ApplyLoggingConfig;
begin
  TLogger.LogLevel := StrToLogLevel(TConfigReader.Instance.LogLevel);
  TLogger.Targets.Clear;
  for var lTarget in TConfigReader.Instance.LoggingTargets do
  begin
    var lLoggingTarget: ILoggingTarget := nil;
    if (lTarget.TargetType = 'File') and (lTarget.Params.Count = 1) then
    begin
      var lDirectory := TPath.Combine(TConfigReader.Instance.ConfigDir, lTarget.Params.Values.ToArray[0]);
      lLoggingTarget := TLoggingTargetFile.Create(lDirectory);
    end
    else if (lTarget.TargetType = 'Pipe') and (lTarget.Params.Count = 1) then
    begin
      lLoggingTarget := TLoggingTargetPipe.Create(lTarget.Params.Values.ToArray[0]);
    end;
    if Assigned(lLoggingTarget) then
    begin
      TLogger.Targets.Add(lLoggingTarget);
    end;
  end;
end;

class function TVdmLogging.StrToLogLevel(const aLogLevelStr: string): TLogLevel;
begin
  Result := TLogLevel.Error;
  for var lLogLevel := Low(TLogLevel) to High(TLogLevel) do
  begin
    if TLogger.LogLevelToStr(lLogLevel) = aLogLevelStr then
      Exit(lLogLevel);
  end;
end;

end.
