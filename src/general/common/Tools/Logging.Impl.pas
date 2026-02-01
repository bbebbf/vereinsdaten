unit Logging.Impl;

interface

uses System.Generics.Collections, InterfacedBase, Logging.Intf;

type
  TLoggingImpl = class(TInterfacedBase, ILogger)
  strict private
    fLogLevel: TLogLevel;
    fTargets: TList<ILoggingTarget>;
    procedure WriteLogText(const aText: string; const aLogLevel: TLogLevel);
    procedure Error(const aText: string);
    procedure Warning(const aText: string);
    procedure Info(const aText: string);
    procedure Debug(const aText: string);
    procedure SetLogLevel(const aLogLevel: TLogLevel);
    function GetLogLevel: TLogLevel;
    function GetTargets: TList<ILoggingTarget>;
    function GetTargetConfigInfos: string;

    procedure LoggingTargetConfigToStr(Sender: TObject; const aElement: ILoggingTarget; var aElementStr: string);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, Joiner;

{ TLoggingImpl }

constructor TLoggingImpl.Create;
begin
  inherited Create;
  fTargets := TList<ILoggingTarget>.Create;
  fLogLevel := TLogLevel.Error;
end;

destructor TLoggingImpl.Destroy;
begin
  fTargets.Free;
  inherited;
end;

procedure TLoggingImpl.Error(const aText: string);
begin
  WriteLogText(aText, TLogLevel.Error);
end;

procedure TLoggingImpl.Warning(const aText: string);
begin
  WriteLogText(aText, TLogLevel.Warning);
end;

procedure TLoggingImpl.Info(const aText: string);
begin
  WriteLogText(aText, TLogLevel.Info);
end;

procedure TLoggingImpl.Debug(const aText: string);
begin
  WriteLogText(aText, TLogLevel.Debug);
end;

function TLoggingImpl.GetLogLevel: TLogLevel;
begin
  Result := fLogLevel;
end;

procedure TLoggingImpl.SetLogLevel(const aLogLevel: TLogLevel);
begin
  fLogLevel := aLogLevel;
end;

function TLoggingImpl.GetTargetConfigInfos: string;
begin
  if fTargets.Count = 0 then
    Exit('');

  var lJoiner := TJoiner<ILoggingTarget>.Create;
  try
    lJoiner.ElementSeparator := ', ';
    lJoiner.OnElementToStr := LoggingTargetConfigToStr;
    lJoiner.Add(fTargets);
    Result := lJoiner.Strings[0];
  finally
    lJoiner.Free;
  end;
end;

function TLoggingImpl.GetTargets: TList<ILoggingTarget>;
begin
  Result := fTargets;
end;

procedure TLoggingImpl.WriteLogText(const aText: string; const aLogLevel: TLogLevel);
begin
  if (aLogLevel > fLogLevel) or (fTargets.Count = 0) then
    Exit;

  var lTimestamp := Now;
  for var lTarget in fTargets do
    lTarget.WriteLogText(lTimestamp, aText, aLogLevel);
end;

procedure TLoggingImpl.LoggingTargetConfigToStr(Sender: TObject; const aElement: ILoggingTarget;
  var aElementStr: string);
begin
  aElementStr := aElement.ConfigurationInfo;
end;

end.
