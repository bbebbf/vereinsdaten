unit Logging.TargetFile;

interface

uses System.Classes, InterfacedBase, Logging.Intf;

type
  TLoggingTargetFile = class(TInterfacedBase, ILoggingTarget)
  strict private
    fDirectory: string;
    fWriter: TStreamWriter;
    function ConfigurationInfo: string;
    procedure InitializeTarget;
    procedure WriteLoggingData(const aLoggingData: TLoggingData);
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

procedure TLoggingTargetFile.InitializeTarget;
begin

end;

function TLoggingTargetFile.ConfigurationInfo: string;
begin
  Result := 'Logging directory: ' + fDirectory;
end;

procedure TLoggingTargetFile.WriteLoggingData(const aLoggingData: TLoggingData);
begin
  if not Assigned(fWriter) then
  begin
    var lFileStream: TFileStream;
    var lFilePath := TPath.Combine(fDirectory, FormatDateTime('yyyy-mm-dd', aLoggingData.TimestampUTC) + '.log');
    if FileExists(lFilePath) then
    begin
      lFileStream := TFile.Open(lFilePath, TFileMode.fmAppend, TFileAccess.faWrite, TFileShare.fsRead);
    end
    else
    begin
      ForceDirectories(ExpandFileName(fDirectory));
      lFileStream := TFile.Open(lFilePath, TFileMode.fmCreate, TFileAccess.faWrite, TFileShare.fsRead);
    end;
    fWriter := TStreamWriter.Create(lFileStream);
    fWriter.OwnStream;
    fWriter.AutoFlush := True;
  end;

  fWriter.WriteLine(aLoggingData.ToString);
end;

end.
