unit Logging.TargetConsole;

interface

uses Winapi.Windows, InterfacedBase, Logging.Intf;

type
  TLoggingTargetConsole = class(TInterfacedBase, ILoggingTarget)
  strict private
    fEscSequencesAllowed: Boolean;
    fConsoleAttached: Boolean;

    function ConfigurationInfo: string;
    procedure InitializeTarget;
    procedure WriteLoggingData(const aLoggingData: TLoggingData);

    procedure AttachOrCreateConsole;
    procedure EnableAnsiMode(const aHandleType: DWORD);
  public
    constructor Create(const aEscSequencesAllowed: Boolean);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils;

{ TLoggingTargetConsole }

constructor TLoggingTargetConsole.Create(const aEscSequencesAllowed: Boolean);
begin
  inherited Create;
  fEscSequencesAllowed := aEscSequencesAllowed;
end;

destructor TLoggingTargetConsole.Destroy;
begin
  if fConsoleAttached then
    FreeConsole;
  inherited;
end;

function TLoggingTargetConsole.ConfigurationInfo: string;
begin
  Result := 'Logging console';
end;

procedure TLoggingTargetConsole.WriteLoggingData(const aLoggingData: TLoggingData);
begin
  AttachOrCreateConsole;
  if not fConsoleAttached then
    Exit;

  WriteLn(Output, aLoggingData.ToString(fEscSequencesAllowed));
end;

procedure TLoggingTargetConsole.AttachOrCreateConsole;
begin
  if fConsoleAttached then
    Exit;

  if AttachConsole(ATTACH_PARENT_PROCESS) then
  begin
    fConsoleAttached := True;
    Writeln;
    Writeln;
  end
  else
  begin
    if GetLastError = ERROR_INVALID_HANDLE then
    begin
      if AllocConsole then
      begin
        fConsoleAttached := True;
      end;
    end;
  end;
  if not fConsoleAttached then
    Exit;

  if fEscSequencesAllowed then
  begin
    EnableAnsiMode(STD_OUTPUT_HANDLE);
    EnableAnsiMode(STD_ERROR_HANDLE);
  end;
end;

procedure TLoggingTargetConsole.EnableAnsiMode(const aHandleType: DWORD);
const
  ENABLE_VIRTUAL_TERMINAL_PROCESSING = $0004;
begin
  var dwMode: DWORD;
  var lHandle := GetStdHandle(STD_ERROR_HANDLE);
  if (lHandle <> INVALID_HANDLE_VALUE) and GetConsoleMode(lHandle, dwMode) then
  begin
    dwMode := dwMode or ENABLE_VIRTUAL_TERMINAL_PROCESSING;
    SetConsoleMode(lHandle, dwMode);
  end;
end;

procedure TLoggingTargetConsole.InitializeTarget;
begin

end;

end.
