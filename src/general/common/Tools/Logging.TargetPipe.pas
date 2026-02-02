unit Logging.TargetPipe;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, Windows, InterfacedBase, Logging.Intf;

type
  TLoggingTargetPipeConnectionResult = (WaitingForClient, ClientConnected, ClosedByClient, ConnectionError);

  TLoggingTargetPipeHandle = class
  strict private
    fPipeName: string;
    fConnectEventHandle: THandle;
    fHandle: THandle;
    fStream: THandleStream;
    fWriter: TStreamWriter;
  public
    constructor Create(const aPipeName: string);
    destructor Destroy; override;
    function InspectConnection: TLoggingTargetPipeConnectionResult;
    property Writer: TStreamWriter read fWriter;
  end;

  TLoggingTargetPipeWriter = reference to procedure(const aWriter: TStreamWriter);

  TLoggingTargetPipe = class(TInterfacedBase, ILoggingTarget)
  strict private
    fName: string;
    fConnections: TObjectList<TLoggingTargetPipeHandle>;

    fConnectEventHandle: THandle;
    fPipeStream: THandleStream;
    fPipeWriter: TStreamWriter;

    function ConfigurationInfo: string;
    procedure WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);

    procedure EnumerateConnections(const aWriterCallback: TLoggingTargetPipeWriter);
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
  end;

implementation

const
  MAX_CLIENT_COUNT = 3;
  BUFFER_SIZE = 4096;

{ TLoggingTargetPipe }

constructor TLoggingTargetPipe.Create(const aName: string);
begin
  inherited Create;
  fConnections := TObjectList<TLoggingTargetPipeHandle>.Create;
  fName := aName;
end;

destructor TLoggingTargetPipe.Destroy;
begin
  fConnections.Free;
  inherited;
end;

function TLoggingTargetPipe.ConfigurationInfo: string;
begin
  Result := 'Logging pipe: ' + fName;
end;

procedure TLoggingTargetPipe.WriteLogText(const aTimestamp: TDateTime; const aText: string; const aLogLevel: TLogLevel);
begin
  var lFormattedText := '[' + FormatDateTime('yyyy-mm-dd hh:nn:ss:zzz', aTimestamp) + '][' +
    TLogger.LogLevelToStr(aLogLevel) + '] ' + aText;
  EnumerateConnections(
    procedure(const aWriter: TStreamWriter)
    begin
      aWriter.WriteLine(lFormattedText);
    end
  );
end;

procedure TLoggingTargetPipe.EnumerateConnections(const aWriterCallback: TLoggingTargetPipeWriter);
begin
  var lWaitingFound := False;
  for var i := fConnections.Count - 1 downto 0 do
  begin
    var lInspectResult := fConnections[i].InspectConnection;
    case lInspectResult of
      TLoggingTargetPipeConnectionResult.WaitingForClient:
      begin
        lWaitingFound := True;
      end;
      TLoggingTargetPipeConnectionResult.ClientConnected:
      begin
        try
          aWriterCallback(fConnections[i].Writer);
        except
          fConnections.Delete(i);
        end;
      end;
      TLoggingTargetPipeConnectionResult.ClosedByClient,
      TLoggingTargetPipeConnectionResult.ConnectionError:
      begin
        fConnections.Delete(i);
      end;
    end;
  end;

  if (fConnections.Count < MAX_CLIENT_COUNT) or not lWaitingFound then
  begin
    var lNewConnection := TLoggingTargetPipeHandle.Create('\\.\pipe\' + fName);
    var lInspectResult := lNewConnection.InspectConnection;
    if lInspectResult in [TLoggingTargetPipeConnectionResult.WaitingForClient,
      TLoggingTargetPipeConnectionResult.ClientConnected] then
    begin
      if lInspectResult = TLoggingTargetPipeConnectionResult.ClientConnected then
      begin
        try
          aWriterCallback(lNewConnection.Writer);
        except
          lNewConnection.Free;
          Exit;
        end;
      end;
      fConnections.Add(lNewConnection);
    end
    else
    begin
      lNewConnection.Free;
    end;
  end;
end;

{ TLoggingTargetPipeHandle }

constructor TLoggingTargetPipeHandle.Create(const aPipeName: string);
begin
  inherited Create;
  fConnectEventHandle := CreateEvent(nil, True, False, nil);

  var lSecurityAttributes := default(SECURITY_ATTRIBUTES);
  lSecurityAttributes.nLength := SizeOf(lSecurityAttributes);
  lSecurityAttributes.lpSecurityDescriptor := nil;
  lSecurityAttributes.bInheritHandle := FALSE;

  fHandle := CreateNamedPipe(
    PWideChar(aPipeName),
    PIPE_ACCESS_OUTBOUND or FILE_FLAG_OVERLAPPED,
    PIPE_TYPE_BYTE or PIPE_READMODE_BYTE or PIPE_WAIT,
    MAX_CLIENT_COUNT,
    BUFFER_SIZE,        // out
    BUFFER_SIZE,        // in
    0,                  // default timeout
    @lSecurityAttributes
  );
  if fHandle <> INVALID_HANDLE_VALUE then
  begin
    fStream := THandleStream.Create(fHandle);
    fWriter := TStreamWriter.Create(fStream, TEncoding.UTF8, BUFFER_SIZE);
  end;
end;

destructor TLoggingTargetPipeHandle.Destroy;
begin
  fWriter.Free;
  fStream.Free;
  CloseHandle(fHandle);
  if fConnectEventHandle > 0 then
    CloseHandle(fConnectEventHandle);
  inherited;
end;

function TLoggingTargetPipeHandle.InspectConnection: TLoggingTargetPipeConnectionResult;
begin
  if fHandle = INVALID_HANDLE_VALUE then
    Exit(TLoggingTargetPipeConnectionResult.ConnectionError);

  var lOverlappedConnect := default(OVERLAPPED);
  lOverlappedConnect.hEvent := fConnectEventHandle;

  var ok := ConnectNamedPipe(fStream.Handle, @lOverlappedConnect);
  if ok then
  begin
    Exit(TLoggingTargetPipeConnectionResult.ClientConnected);
  end
  else
  begin
    case GetLastError of
      ERROR_IO_PENDING:
      begin
        var lWaitResult := WaitForSingleObject(lOverlappedConnect.hEvent, 1);
        if lWaitResult = WAIT_OBJECT_0 then
          Exit(TLoggingTargetPipeConnectionResult.ClientConnected)
        else
          Exit(TLoggingTargetPipeConnectionResult.WaitingForClient)
      end;
      ERROR_PIPE_CONNECTED:
        Exit(TLoggingTargetPipeConnectionResult.ClientConnected);
      ERROR_NO_DATA:
        Exit(TLoggingTargetPipeConnectionResult.ClosedByClient);
      else
        Exit(TLoggingTargetPipeConnectionResult.ConnectionError);
    end;
  end;
end;

end.
