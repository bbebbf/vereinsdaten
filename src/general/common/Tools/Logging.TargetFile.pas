unit Logging.TargetFile;

interface

uses System.Classes, InterfacedBase, Logging.Intf;

type
  TLoggingTargetFile = class(TInterfacedBase, ILoggingTarget)
  strict private
    fDirectory: string;
    fWriter: TStreamWriter;
    procedure WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);
  public
    constructor Create(const aDirectory: string);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, System.IOUtils;

{ TLoggingTargetFile }

constructor TLoggingTargetFile.Create(const aDirectory: string);
begin
  inherited Create;
  fDirectory := aDirectory;
end;

destructor TLoggingTargetFile.Destroy;
begin
  fWriter.Free;
  inherited;
end;

procedure TLoggingTargetFile.WriteLogText(const aTimestamp: TDateTime;
  const aText: string; const aLogLevel: TLogLevel);
begin
  if not Assigned(fWriter) then
  begin
    var lFileStream: TFileStream;
    var lFilePath := TPath.Combine(fDirectory, FormatDateTime('yyyy-mm-dd', aTimestamp) + '.log');
    if FileExists(lFilePath) then
    begin
      lFileStream := TFile.Open(lFilePath, TFileMode.fmAppend, TFileAccess.faWrite, TFileShare.fsRead);
    end
    else
    begin
      ForceDirectories(fDirectory);
      lFileStream := TFile.Open(lFilePath, TFileMode.fmCreate, TFileAccess.faWrite, TFileShare.fsRead);
    end;
    fWriter := TStreamWriter.Create(lFileStream);
    fWriter.OwnStream;
    fWriter.AutoFlush := True;
  end;

  var lFormattedText := '[' + FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', aTimestamp) + '][' +
    TLogger.LogLevelToStr(aLogLevel) + '] ' + aText;
  fWriter.WriteLine(lFormattedText);
end;

end.
