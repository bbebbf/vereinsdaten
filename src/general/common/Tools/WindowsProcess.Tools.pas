unit WindowsProcess.Tools;

interface

uses Winapi.Windows;

type
  TWindowsProcessTools = class
  strict private
    class var fPROCESS_QUERY_LIMITED_INFORMATION_Available: Byte;
    class var fLastError: Cardinal;
  public
    const
      DWORD_MAXVALUE = High(DWORD);
    class procedure CloseThisHandle(var aHandle: THandle);
    class function GetExecutablePath(const aProcessId: Cardinal; out aExePath: string): Boolean;
    class function OpenProcess(const aDesiredAccess: Cardinal; const aInheritHandle: Boolean; const aProcessId: Cardinal): THandle;
    class function OpenProcessQueryInformation(const aInheritHandle: Boolean; const aProcessId: Cardinal): THandle;
    class function GetCurrentSessionId(out aSessionId: Cardinal): Boolean;
    class function GetSessionIdForProcessId(const aProcessId: Cardinal; out aSessionId: Cardinal): Boolean;
    class property LastError: Cardinal read fLastError;
  end;

implementation

uses Winapi.TLHelp32;

const
  PROCESS_QUERY_LIMITED_INFORMATION = $1000;

function QueryFullProcessImageNameW(hProcess: THandle; dwFlags: DWORD; lpExeName: LPCWSTR; var lpdwSize: Cardinal): BOOL; stdcall;
  external 'kernel32.dll';

function WTSGetActiveConsoleSessionId: DWORD; stdcall;
  external 'kernel32.dll';

function ProcessIdToSessionId(dwProcessId: DWORD; var pSessionId: DWORD): BOOL; stdcall;
  external 'kernel32.dll';

{ TWindowsProcessTools }

class procedure TWindowsProcessTools.CloseThisHandle(var aHandle: THandle);
begin
  if aHandle = 0 then
    Exit;
  Winapi.Windows.CloseHandle(aHandle);
  aHandle := 0;
end;

class function TWindowsProcessTools.GetCurrentSessionId(
  out aSessionId: Cardinal): Boolean;
begin
  Result := True;
  aSessionId := WTSGetActiveConsoleSessionId;
  if aSessionId = DWORD_MAXVALUE then
  begin
    Result := False;
    aSessionId := 0;
  end;
end;

class function TWindowsProcessTools.GetExecutablePath(const aProcessId: Cardinal; out aExePath: string): Boolean;
var lProcessHandle: THandle;
  lStrLen: Cardinal;
  lpWchPath: array[0..MAX_PATH - 1] of Char;
begin
  Result := False;
  aExePath := '';
  if aProcessId = 0 then
    Exit;

  lProcessHandle := OpenProcessQueryInformation(False, aProcessId);
  try
    if lProcessHandle = 0 then
      Exit;

    lStrLen := Length(lpWchPath);
    if QueryFullProcessImageNameW(lProcessHandle, 0, @lpWchPath, lStrLen) then
    begin
      Result := True;
      aExePath := Copy(lpWchPath, 1, lStrLen);
    end;
  finally
    CloseThisHandle(lProcessHandle);
  end;
end;

class function TWindowsProcessTools.GetSessionIdForProcessId(const aProcessId: Cardinal; out aSessionId: Cardinal): Boolean;
begin
  Result := False;
  if aProcessId = 0 then
    Exit;

  if ProcessIdToSessionId(aProcessId, aSessionId) then
  begin
    Result := True;
  end
  else
  begin
    aSessionId := 0;
  end;
end;

class function TWindowsProcessTools.OpenProcess(const aDesiredAccess: Cardinal;
  const aInheritHandle: Boolean; const aProcessId: Cardinal): THandle;
begin
  Result := Winapi.Windows.OpenProcess(aDesiredAccess, aInheritHandle, aProcessId);
  if Result = 0 then
    fLastError := Winapi.Windows.GetLastError;
end;

class function TWindowsProcessTools.OpenProcessQueryInformation(const aInheritHandle: Boolean; const aProcessId: Cardinal): THandle;
begin
  if fPROCESS_QUERY_LIMITED_INFORMATION_Available = 0 then
  begin
    Result := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, aInheritHandle, aProcessId);
    if (Result > 0) or ((Result = 0) and (fLastError = ERROR_ACCESS_DENIED)) then
    begin
      fPROCESS_QUERY_LIMITED_INFORMATION_Available := 1;
    end
    else
    begin
      fPROCESS_QUERY_LIMITED_INFORMATION_Available := 2;
      Result := OpenProcess(PROCESS_QUERY_INFORMATION, aInheritHandle, aProcessId);
    end;
  end
  else if fPROCESS_QUERY_LIMITED_INFORMATION_Available = 1 then
  begin
    Result := OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, aInheritHandle, aProcessId);
  end
  else
  begin
      Result := OpenProcess(PROCESS_QUERY_INFORMATION, aInheritHandle, aProcessId);
  end;
end;

end.
