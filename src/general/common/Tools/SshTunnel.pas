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

function CreateSshTunnelProcess(const aLocalPort: Integer;
      const aSshHost: string; const aSshPort: Integer;
      const aRemoteHost: string; const aRemotePort: Integer): ISshTunnel;

implementation

uses System.SysUtils, InterfacedBase, Winapi.Windows, WindowsProcess;

type
  TSshTunnel = class(TInterfacedBase, ISshTunnel)
  strict private
    fSshHost: string;
    fSshPort: Integer;
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
    constructor Create(const aLocalPort: Integer;
      const aSshHost: string; const aSshPort: Integer;
      const aRemoteHost: string; const aRemotePort: Integer);
    destructor Destroy; override;
  end;

function CreateSshTunnelProcess(const aLocalPort: Integer;
      const aSshHost: string; const aSshPort: Integer;
      const aRemoteHost: string; const aRemotePort: Integer): ISshTunnel;
begin
  Result := TSshTunnel.Create(aLocalPort, aSshHost, aSshPort, aRemoteHost, aRemotePort);
end;

{ TSshTunnel }

constructor TSshTunnel.Create(const aLocalPort: Integer;
      const aSshHost: string; const aSshPort: Integer;
      const aRemoteHost: string; const aRemotePort: Integer);
begin
  inherited Create;
  fLocalPort := aLocalPort;
  fSshHost := aSshHost;
  fSshPort := aSshPort;
  fRemoteHost := aRemoteHost;
  fRemotePort := aRemotePort;
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
  var lRemoteHost := fRemoteHost;
  if Length(lRemoteHost) = 0 then
    lRemoteHost := 'localhost';

  Result := 'ssh.exe -N -L' +
    ' localhost:' + IntToStr(fLocalPort) +
    ':' + lRemoteHost + ':' + IntToStr(fRemotePort) +
    ' ' + fSshHost;
  if (fSshPort > 0) and (fSshPort <> 22) then
    Result := Result + ' -p ' + IntToStr(fSshPort);
end;

end.
