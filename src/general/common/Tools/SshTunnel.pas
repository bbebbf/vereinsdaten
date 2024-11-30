unit SshTunnel;

interface

type
  ISshTunnel = interface
    ['{2BE63029-D337-42CD-B3CE-D5D4007B0D8E}']
    function Connect: Boolean;
    procedure Disconnect;
    function GetLocalPort: Integer;
    property LocalPort: Integer read GetLocalPort;
  end;

function CreateSshTunnelProcess(const aRemoteHost: string; const aRemotePort, aLocalPort: Integer): ISshTunnel;

implementation

uses System.SysUtils, Winapi.Windows, WindowsProcess;

type
  TSshTunnel = class(TInterfacedObject, ISshTunnel)
  strict private
    fRemoteHost: string;
    fRemotePort: Integer;
    fLocalPort: Integer;
    fSshProcess: TNewWindowsProcess;
    function Connect: Boolean;
    procedure Disconnect;
    function GetLocalPort: Integer;
    function ComposeCommandline: string;
    function GetWorkingDir: string;
  public
    constructor Create(const aRemoteHost: string; const aRemotePort, aLocalPort: Integer);
    destructor Destroy; override;
  end;

function CreateSshTunnelProcess(const aRemoteHost: string; const aRemotePort, aLocalPort: Integer): ISshTunnel;
begin
  Result := TSshTunnel.Create(aRemoteHost, aRemotePort, aLocalPort);
end;

{ TSshTunnel }

constructor TSshTunnel.Create(const aRemoteHost: string; const aRemotePort, aLocalPort: Integer);
begin
  inherited Create;
  fRemoteHost := aRemoteHost;
  fRemotePort := aRemotePort;
  fLocalPort := aLocalPort;
end;

destructor TSshTunnel.Destroy;
begin
  Disconnect;
  inherited;
end;

function TSshTunnel.Connect: Boolean;
begin
  if not Assigned(fSshProcess) then
  begin
    fSshProcess := TNewWindowsProcess.Create(ComposeCommandline, GetWorkingDir);
    fSshProcess.StartupFlags := STARTF_USESHOWWINDOW;
    fSshProcess.ShowWindowFlags := SW_HIDE;
  end;
  if fSshProcess.IsRunning then
    Exit(True);
  Result := fSshProcess.CreateProcess;
end;

procedure TSshTunnel.Disconnect;
begin
  if Assigned(fSshProcess) then
  begin
    fSshProcess.Terminate;
    FreeAndNil(fSshProcess);
  end;
end;

function TSshTunnel.GetLocalPort: Integer;
begin
  Result := 0;
  if Assigned(fSshProcess) and fSshProcess.IsRunning then
    Result := fLocalPort;
end;

function TSshTunnel.GetWorkingDir: string;
begin
  Result := '';
end;

function TSshTunnel.ComposeCommandline: string;
begin
  Result := 'ssh.exe -N -L ' + IntToStr(fLocalPort)+':localhost:' + IntToStr(fRemotePort) +
    ' ' + fRemoteHost;
end;

end.
