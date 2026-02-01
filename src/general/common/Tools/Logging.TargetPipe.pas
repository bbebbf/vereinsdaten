unit Logging.TargetPipe;

interface

uses System.Classes, System.SysUtils, Windows, InterfacedBase, Logging.Intf;

type
  TLoggingTargetPipe = class(TInterfacedBase, ILoggingTarget)
  strict private
    fName: string;
    fConnectEventHandle: THandle;
    fPipeStream: THandleStream;
    fPipeWriter: TStreamWriter;

    function ConfigurationInfo: string;
    procedure WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);

    function InitializePipe: Boolean;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
  end;

implementation

const
  BUFFER_SIZE = 4096;

{ TLoggingTargetPipe }

constructor TLoggingTargetPipe.Create(const aName: string);
begin
  inherited Create;
  fConnectEventHandle := CreateEvent(nil, True, False, nil);
  fName := aName;
end;

destructor TLoggingTargetPipe.Destroy;
begin
  fPipeWriter.Free;
  if Assigned(fPipeStream) then
  begin
    CloseHandle(fPipeStream.Handle);
    fPipeStream.Free;
  end;
  if fConnectEventHandle > 0 then
    CloseHandle(fConnectEventHandle);
  inherited;
end;

function TLoggingTargetPipe.ConfigurationInfo: string;
begin
  Result := 'Logging pipe: ' + fName;
end;

function TLoggingTargetPipe.InitializePipe: Boolean;
begin
  Result := False;
  if fConnectEventHandle = 0 then
    Exit(False);

 for var i := 1 to 2 do
 begin
    if not Assigned(fPipeStream) then
    begin
      var lSecurityAttributes := default(SECURITY_ATTRIBUTES);
      lSecurityAttributes.nLength := SizeOf(lSecurityAttributes);
      lSecurityAttributes.lpSecurityDescriptor := nil;
      lSecurityAttributes.bInheritHandle := FALSE;

      var lPipeHandle := CreateNamedPipe(
        PWideChar('\\.\pipe\' + fName),
        PIPE_ACCESS_OUTBOUND or FILE_FLAG_OVERLAPPED,
        PIPE_TYPE_BYTE or PIPE_READMODE_BYTE or PIPE_WAIT,
        PIPE_UNLIMITED_INSTANCES,
        BUFFER_SIZE,        // out
        BUFFER_SIZE,        // in
        0,                  // default timeout
        @lSecurityAttributes
      );
      if lPipeHandle = INVALID_HANDLE_VALUE then
        Exit(False);

      fPipeStream := THandleStream.Create(lPipeHandle);

      fPipeWriter.Free;
      fPipeWriter := TStreamWriter.Create(fPipeStream, TEncoding.UTF8, BUFFER_SIZE);
    end;

    var lOverlappedConnect := default(OVERLAPPED);
    lOverlappedConnect.hEvent := fConnectEventHandle;

    var ok := ConnectNamedPipe(fPipeStream.Handle, @lOverlappedConnect);
    if ok then
    begin
      Exit(True);
    end
    else
    begin
      case GetLastError of
        ERROR_IO_PENDING:
        begin
          var lWaitResult := WaitForSingleObject(lOverlappedConnect.hEvent, 1);
          Exit(lWaitResult = WAIT_OBJECT_0);
        end;
        ERROR_PIPE_CONNECTED:
        begin
          Exit(True);
        end;
        ERROR_NO_DATA:
        begin
          FreeAndNil(fPipeWriter);
          FreeAndNil(fPipeStream);
        end;
        else
          Exit(False);
      end;
    end;
  end;
end;

procedure TLoggingTargetPipe.WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);
begin
  if not InitializePipe then
    Exit;
  var lFormattedText := '[' + FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', aTimestamp) + '][' +
    TLogger.LogLevelToStr(aLogLevel) + '] ' + aText;
  fPipeWriter.WriteLine(lFormattedText);
end;

end.
