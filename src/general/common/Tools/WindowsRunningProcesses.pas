unit WindowsRunningProcesses;

interface

uses System.SysUtils, System.Generics.Collections;

type
  TWindowsProcessInfo = record
    ProcessId: Cardinal;
    ExeName: string;
    ExePath: string;
    ExePathSet: Boolean;
    ExePathDenied: Boolean;
    SessionId: Cardinal;
    SessionIdSet: Boolean;
  end;

  TWindowsRunningProcessesOption = (QueryExePath, QuerySessionId, AllSessions);
  TWindowsRunningProcessesOptions = set of TWindowsRunningProcessesOption;

  TWindowsRunningProcesses = class(TEnumerable<TWindowsProcessInfo>)
  strict private
    fPredicate: TPredicate<TWindowsProcessInfo>;
    fOptions: TWindowsRunningProcessesOptions;
  protected
    function DoGetEnumerator: TEnumerator<TWindowsProcessInfo>; override;
  public
    type
      TEnumerator = class(TEnumerator<TWindowsProcessInfo>)
      strict private
        fCurrentSessionId: Cardinal;
        fPredicate: TPredicate<TWindowsProcessInfo>;
        fOptions: TWindowsRunningProcessesOptions;
        fProcessSnapshotHandle: THandle;
        fFirstProcessDone: Boolean;
        fCurrentProcessInfo: TWindowsProcessInfo;
        function GetCurrent: TWindowsProcessInfo;
        procedure DetermimeExePath(var aProcessInfo: TWindowsProcessInfo);
        procedure DetermimeSessionId(var aProcessInfo: TWindowsProcessInfo);
      protected
        function DoGetCurrent: TWindowsProcessInfo; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const aOptions: TWindowsRunningProcessesOptions; const aPredicate: TPredicate<TWindowsProcessInfo>);
        destructor Destroy; override;
        property Current: TWindowsProcessInfo read GetCurrent;
        function MoveNext: Boolean;
      end;

    constructor Create(const aPredicate: TPredicate<TWindowsProcessInfo> = nil); overload;
    constructor Create(const aOptions: TWindowsRunningProcessesOptions; const aPredicate: TPredicate<TWindowsProcessInfo> = nil); overload;
    function GetEnumerator: TEnumerator; reintroduce; inline;
  end;

implementation

uses Winapi.Windows, Winapi.TLHelp32, WindowsProcess.Tools;

{ TWindowsRunningProcesses }

constructor TWindowsRunningProcesses.Create(const aPredicate: TPredicate<TWindowsProcessInfo>);
begin
  Create([TWindowsRunningProcessesOption.QuerySessionId,
    TWindowsRunningProcessesOption.QueryExePath], aPredicate);
end;

constructor TWindowsRunningProcesses.Create(const aOptions: TWindowsRunningProcessesOptions;
  const aPredicate: TPredicate<TWindowsProcessInfo>);
begin
  inherited Create;
  fOptions := aOptions;
  fPredicate := aPredicate
end;

function TWindowsRunningProcesses.DoGetEnumerator: TEnumerator<TWindowsProcessInfo>;
begin
  Result := GetEnumerator;
end;

function TWindowsRunningProcesses.GetEnumerator: TEnumerator;
begin
  Result := TEnumerator.Create(fOptions, fPredicate);
end;

{ TWindowsRunningProcesses.TEnumerator }

constructor TWindowsRunningProcesses.TEnumerator.Create(const aOptions: TWindowsRunningProcessesOptions;
  const aPredicate: TPredicate<TWindowsProcessInfo>);
begin
  inherited Create;
  if not TWindowsProcessTools.GetCurrentSessionId(fCurrentSessionId) then
    fCurrentSessionId := 0;
  fOptions := aOptions;
  fPredicate := aPredicate;
end;

destructor TWindowsRunningProcesses.TEnumerator.Destroy;
begin
  TWindowsProcessTools.CloseThisHandle(fProcessSnapshotHandle);
  inherited;
end;

function TWindowsRunningProcesses.TEnumerator.DoGetCurrent: TWindowsProcessInfo;
begin
  Result := GetCurrent;
end;

function TWindowsRunningProcesses.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TWindowsRunningProcesses.TEnumerator.GetCurrent: TWindowsProcessInfo;
begin
  Result := fCurrentProcessInfo;
end;

function TWindowsRunningProcesses.TEnumerator.MoveNext: Boolean;
var lProcessEntry: TProcessEntry32;
  lProcessMatches: Boolean;
  lSameSession: Boolean;
begin
  Result := False;
  lProcessMatches := False;
  lProcessEntry := default(TProcessEntry32);
  lProcessEntry.dwSize := SizeOf(ProcessEntry32);
  repeat
    if fFirstProcessDone then
    begin
      Result := Process32Next(fProcessSnapshotHandle, lProcessEntry);
    end
    else
    begin
      fFirstProcessDone := True;
      TWindowsProcessTools.CloseThisHandle(fProcessSnapshotHandle);
      fProcessSnapshotHandle := CreateToolHelp32SnapShot(TH32CS_SNAPPROCESS, 0);
      if fProcessSnapshotHandle = INVALID_HANDLE_VALUE then
        Exit;

      Result := Process32First(fProcessSnapshotHandle, lProcessEntry);
    end;

    if not Result then
      Exit;

    fCurrentProcessInfo := default(TWindowsProcessInfo);
    if lProcessEntry.th32ProcessID > 0 then
    begin
      fCurrentProcessInfo.ProcessId := lProcessEntry.th32ProcessID;
      fCurrentProcessInfo.ExeName := lProcessEntry.szExeFile;

      lSameSession := not (TWindowsRunningProcessesOption.AllSessions in fOptions);
      if (TWindowsRunningProcessesOption.QuerySessionId in fOptions) or lSameSession then
        DetermimeSessionId(fCurrentProcessInfo);

      lProcessMatches := True;
      if lSameSession then
      begin
        if fCurrentSessionId = 0 then
        begin
          Exit(False);
        end
        else if (fCurrentSessionId <> fCurrentProcessInfo.SessionId) or
          not fCurrentProcessInfo.SessionIdSet then
        begin
          lProcessMatches := False;
        end;
      end;

      if lProcessMatches then
      begin
        if TWindowsRunningProcessesOption.QueryExePath in fOptions then
          DetermimeExePath(fCurrentProcessInfo);
        if Assigned(fPredicate) then
          lProcessMatches := fPredicate(fCurrentProcessInfo);
      end;
    end;

  until lProcessMatches;
end;

procedure TWindowsRunningProcesses.TEnumerator.DetermimeExePath(var aProcessInfo: TWindowsProcessInfo);
begin
  aProcessInfo.ExePath := '';
  aProcessInfo.ExePathSet := False;
  aProcessInfo.ExePathDenied := False;
  if TWindowsProcessTools.GetExecutablePath(aProcessInfo.ProcessId, aProcessInfo.ExePath) then
  begin
    aProcessInfo.ExePathSet := True;
  end
  else if TWindowsProcessTools.LastError = ERROR_ACCESS_DENIED then
  begin
    aProcessInfo.ExePathDenied := True;
  end;
end;

procedure TWindowsRunningProcesses.TEnumerator.DetermimeSessionId(var aProcessInfo: TWindowsProcessInfo);
begin
  aProcessInfo.SessionId := 0;
  aProcessInfo.SessionIdSet := False;
  if TWindowsProcessTools.GetSessionIdForProcessId(aProcessInfo.ProcessId, aProcessInfo.SessionId) then
    aProcessInfo.SessionIdSet := True;
end;

end.
