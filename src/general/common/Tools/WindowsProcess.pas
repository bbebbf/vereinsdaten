unit WindowsProcess;

interface

uses System.SysUtils, System.Classes, System.Generics.Collections, System.SyncObjs;

type
  TWindowsProcessBase = class
  strict private
    fRepoKey: TObject;
    fCriticalSection: TCriticalSection;
    fProcessThreads: TList<THandle>;
    fExitWaitHandle: THandle;
    fOnTerminated: TNotifyEvent;
    function GetExitCode: Cardinal;
    function GetIsRunning: Boolean;
    function GetMyLastError: Cardinal;
    function GetOnTerminated: TNotifyEvent;
    procedure SetOnTerminated(const aValue: TNotifyEvent);
    procedure SetMyLastError(const aValue: Cardinal);
  strict protected
    function RegisterExitCallback: Boolean;
    function ResumeProcessThreads: Boolean;
  protected
    fProcessCreated: Boolean;
    fProcessId: Cardinal;
    fProcessHandle: THandle;
    fLastError: Cardinal;
    fExitCode: Cardinal;
    fIsRunning: Boolean;
    procedure CloseProcessThreads;
    procedure UnregisterExitCallback;
    property CriticalSection: TCriticalSection read fCriticalSection;
    property ProcessThreads: TList<THandle> read fProcessThreads;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>
    ///   Terminates the started windows process in advance.
    /// </summary>
    /// <param name="anExitCodeForTermination">
    ///    The desired exit code the terminated process will have.
    /// </param>
    /// <returns>
    ///   TRUE, if successful
    ///   FALSE otherwise
    /// </returns>
    function Terminate(const anExitCodeForTermination: Cardinal = 1): Boolean;

    property ProcessId: Cardinal read fProcessId;
    property LastError: Cardinal read GetMyLastError;
    property ExitCode: Cardinal read GetExitCode;
    property IsRunning: Boolean read GetIsRunning;
    /// <summary>
    ///   This event will be fired after the process has naturally or forced terminated.
    /// </summary>
    property OnTerminated: TNotifyEvent read GetOnTerminated write SetOnTerminated;
  end;

  TNewWindowsProcess = class(TWindowsProcessBase)
  strict private
    fCommandLine: string;
    fWorkingDirectory: string;
    fShowWindowFlags: Word;
    fShowWindowFlagsSet: Boolean;
    fProcessCreationFlags: Cardinal;
    fStartupFlags: Cardinal;
    fStartupFlagsSet: Boolean;
    procedure SetShowWindowFlags(const aValue: Word);
    procedure SetStartupFlags(const aValue: Cardinal);
    procedure CreateTheProcessSuspended;
  public
    constructor Create(const aCommandLine: string; const aWorkingDirectory: string = '');
    /// <summary>
    ///   Starts the defined windows process.
    /// </summary>
    function CreateProcess: Boolean;
    property ProcessCreationFlags: Cardinal read fProcessCreationFlags write fProcessCreationFlags;
    property ShowWindowFlags: Word read fShowWindowFlags write SetShowWindowFlags;
    property StartupFlags: Cardinal read fStartupFlags write SetStartupFlags;
    property CommandLine: string read fCommandLine;
    property WorkingDirectory: string read fWorkingDirectory;
  end;

  TExistingWindowsProcess = class(TWindowsProcessBase)
  strict private
    fDesiredProcessId: Cardinal;
    procedure ConnectToDesiredProcessSuspended;
  public
    constructor Create(const aDesiredProcessId: Cardinal);
    /// <summary>
    ///   Opens the desired windows process.
    /// </summary>
    function OpenProcess: Boolean;
    property DesiredProcessId: Cardinal read fProcessId;
  end;

implementation

uses Winapi.Windows, Winapi.TLHelp32, WindowsProcess.Tools;

type
  TWindowsProcessRepository = class
  strict private
    class var
      fInstance: TWindowsProcessRepository;
      fCriticalSection: TCriticalSection;
    var
      fDictionaryCriticalSection: TCriticalSection;
      fDictionary: TObjectDictionary<TObject,TWindowsProcessBase>;
    class function GetInstance: TWindowsProcessRepository; static;
  public
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class property Instance: TWindowsProcessRepository read GetInstance;
    constructor Create;
    destructor Destroy; override;
    function Add(const aValue: TWindowsProcessBase): TObject;
    procedure Remove(const aKey: TObject);
    function TryGetValue(const aKey: TObject; out aValue: TWindowsProcessBase): Boolean;
  end;

function OpenThread(DesiredAccess: DWORD; InheritHandle: BOOL; ThreadId: DWORD): THandle; stdcall; external 'kernel32.dll';

procedure ProcessTimeoutOrExited(aContext: Pointer; aSuccess: Boolean); stdcall;
var lRepoKey: TObject;
  lProcess: TWindowsProcessBase;
  lExitCode: DWORD;
begin
  if aSuccess then
    Exit;

  {$WARN UNSAFE_CAST OFF}
  lRepoKey := TObject(aContext);
  {$WARN UNSAFE_CAST ON}

  if not TWindowsProcessRepository.Instance.TryGetValue(lRepoKey, lProcess) then
    Exit;

  lProcess.CriticalSection.Enter;
  try
    lProcess.fIsRunning := False;
    if GetExitCodeProcess(lProcess.fProcessHandle, lExitCode) then
    begin
      lProcess.fExitCode := lExitCode;
    end
    else
    begin
      lProcess.fLastError := GetLastError;
    end;
    lProcess.CloseProcessThreads;
    TWindowsProcessTools.CloseThisHandle(lProcess.fProcessHandle);
    if Assigned(lProcess.OnTerminated) then
    begin
      lProcess.OnTerminated(lProcess);
    end;
  finally
    lProcess.CriticalSection.Leave;
  end;
end;

{ TWindowsProcessBase }

constructor TWindowsProcessBase.Create;
begin
  inherited Create;
  fCriticalSection := TCriticalSection.Create;
  fProcessThreads := TList<THandle>.Create;
end;

destructor TWindowsProcessBase.Destroy;
begin
  fOnTerminated := nil;
  UnregisterExitCallback;
  CloseProcessThreads;
  TWindowsProcessTools.CloseThisHandle(fProcessHandle);
  fProcessThreads.Free;
  fCriticalSection.Free;
  inherited;
end;

procedure TWindowsProcessBase.CloseProcessThreads;
var lThreadHandle: THandle;
begin
  for lThreadHandle in fProcessThreads do
    Winapi.Windows.CloseHandle(lThreadHandle);
  fProcessThreads.Clear;
end;

function TWindowsProcessBase.ResumeProcessThreads: Boolean;
var lThreadHandle: THandle;
begin
  Result := True;
  for lThreadHandle in fProcessThreads do
  begin
    if Winapi.Windows.ResumeThread(lThreadHandle) = TWindowsProcessTools.DWORD_MAXVALUE then
      Result := False;
  end;
end;

function TWindowsProcessBase.Terminate(const anExitCodeForTermination: Cardinal): Boolean;
var lExitCode: DWORD;
begin
  Result := False;
  if not fProcessCreated then
    Exit;

  if GetExitCodeProcess(fProcessHandle, lExitCode) then
  begin
    if lExitCode = STILL_ACTIVE then
    begin
      if Winapi.Windows.TerminateProcess(fProcessHandle, anExitCodeForTermination) then
        Exit(True)
      else
        SetMyLastError(GetLastError);
    end
    else
    begin
      fExitCode := lExitCode;
      Exit(True);
    end;
  end
  else
  begin
    SetMyLastError(GetLastError);
  end;
end;

function TWindowsProcessBase.RegisterExitCallback: Boolean;
var lRegisterResult: Boolean;
begin
  Result := True;
  if Assigned(fRepoKey) then
    TWindowsProcessRepository.Instance.Remove(fRepoKey);
  fRepoKey := TWindowsProcessRepository.Instance.Add(Self);
  {$WARN UNSAFE_CAST OFF}
  lRegisterResult := Winapi.Windows.RegisterWaitForSingleObject(fExitWaitHandle, fProcessHandle,
    ProcessTimeoutOrExited, fRepoKey, INFINITE, WT_EXECUTEONLYONCE);
  {$WARN UNSAFE_CAST ON}
  if not lRegisterResult then
  begin
    Result := False;
    TWindowsProcessRepository.Instance.Remove(fRepoKey);
    fRepoKey := nil;
    SetMyLastError(GetLastError);
    fExitWaitHandle := 0;
  end;
end;

procedure TWindowsProcessBase.UnregisterExitCallback;
begin
  if fExitWaitHandle = 0 then
    Exit;

  CriticalSection.Enter;
  try
    if Winapi.Windows.UnregisterWait(fExitWaitHandle) then
    begin
      TWindowsProcessRepository.Instance.Remove(fRepoKey);
      fRepoKey := nil;
      fExitWaitHandle := 0;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

function TWindowsProcessBase.GetExitCode: Cardinal;
begin
  CriticalSection.Enter;
  try
    Result := fExitCode;
  finally
    CriticalSection.Leave;
  end;
end;

function TWindowsProcessBase.GetIsRunning: Boolean;
begin
  CriticalSection.Enter;
  try
    Result := fIsRunning;
  finally
    CriticalSection.Leave;
  end;
end;

function TWindowsProcessBase.GetMyLastError: Cardinal;
begin
  CriticalSection.Enter;
  try
    Result := fLastError;
  finally
    CriticalSection.Leave;
  end;
end;

function TWindowsProcessBase.GetOnTerminated: TNotifyEvent;
begin
  CriticalSection.Enter;
  try
    Result := fOnTerminated;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TWindowsProcessBase.SetOnTerminated(const aValue: TNotifyEvent);
begin
  if fProcessCreated or (fExitWaitHandle > 0) then
    Exit;

  CriticalSection.Enter;
  try
    fOnTerminated := aValue;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TWindowsProcessBase.SetMyLastError(const aValue: Cardinal);
begin
  CriticalSection.Enter;
  try
    fLastError := aValue;
  finally
    CriticalSection.Leave;
  end;
end;

{ TNewWindowsProcess }

constructor TNewWindowsProcess.Create(const aCommandLine, aWorkingDirectory: string);
begin
  inherited Create;
  fCommandLine := aCommandLine;
  fWorkingDirectory := aWorkingDirectory;
  fProcessCreationFlags := CREATE_DEFAULT_ERROR_MODE or NORMAL_PRIORITY_CLASS;
end;

function TNewWindowsProcess.CreateProcess: Boolean;
begin
  if fProcessCreated then
    Exit(False);

  Result := True;
  try
    CreateTheProcessSuspended;
    if not fProcessCreated then
      Exit(False);
    if ProcessThreads.Count = 0 then
      Exit(False);

    if not RegisterExitCallback then
      Exit(False);
  finally
    if not ResumeProcessThreads then
      Result := False;
  end;
end;

procedure TNewWindowsProcess.CreateTheProcessSuspended;
var
  lStartupInfo: TStartupInfo;
  lProcessInformation: TProcessInformation;
  lWorkingDirPWideChar: PWideChar;
begin
  lStartupInfo := default(TStartupInfo);
  lStartupInfo.cb := SizeOf(lStartupInfo);
  if fShowWindowFlagsSet then
    lStartupInfo.wShowWindow := fShowWindowFlags;
  if fStartupFlagsSet then
    lStartupInfo.dwFlags := fStartupFlags;
  if Length(fWorkingDirectory) > 0 then
    lWorkingDirPWideChar := PWideChar(fWorkingDirectory)
  else
    lWorkingDirPWideChar := nil;

  CriticalSection.Enter;
  try
    fProcessCreated := Winapi.Windows.CreateProcess(nil, PWideChar(fCommandLine), nil, nil, False,
      fProcessCreationFlags or CREATE_SUSPENDED, nil, lWorkingDirPWideChar, lStartupInfo, lProcessInformation);
    if fProcessCreated then
    begin
      fIsRunning := True;
      fProcessHandle := lProcessInformation.hProcess;
      ProcessThreads.Add(lProcessInformation.hThread);
      fProcessId := lProcessInformation.dwProcessId;
    end
    else
    begin
      fLastError := Winapi.Windows.GetLastError;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

procedure TNewWindowsProcess.SetShowWindowFlags(const aValue: Word);
begin
  fShowWindowFlags := aValue;
  fShowWindowFlagsSet := True;
end;

procedure TNewWindowsProcess.SetStartupFlags(const aValue: Cardinal);
begin
  fStartupFlags := aValue;
  fStartupFlagsSet := True;
end;

{ TExistingWindowsProcess }

constructor TExistingWindowsProcess.Create(const aDesiredProcessId: Cardinal);
begin
  inherited Create;
  fDesiredProcessId := aDesiredProcessId;
end;

function TExistingWindowsProcess.OpenProcess: Boolean;
begin
  if fProcessCreated then
    Exit(False);

  try
    Result := True;
    ConnectToDesiredProcessSuspended;
    if not fProcessCreated then
      Exit(False);
    if ProcessThreads.Count = 0 then
      Exit(False);

    if not RegisterExitCallback then
      Exit(False);
  finally
    if not ResumeProcessThreads then
      Result := False;
  end;
end;

procedure TExistingWindowsProcess.ConnectToDesiredProcessSuspended;
const
  PROCESS_SUSPEND_RESUME = $0800;
  THREAD_SUSPEND_RESUME = $0002;
var
  lThreadSnapHandle: THandle;
  lThreadEntry: THREADENTRY32;
  lThreadHandle: THandle;
begin
  CriticalSection.Enter;
  try
    fProcessHandle := Winapi.Windows.OpenProcess(
      PROCESS_QUERY_INFORMATION or PROCESS_SUSPEND_RESUME or PROCESS_TERMINATE or SYNCHRONIZE,
      False, fDesiredProcessId);
    if fProcessHandle > 0 then
    begin
      fIsRunning := True;
      fProcessCreated := True;
      fProcessId := fDesiredProcessId;

      // Collecting all process threads and suspending them.
      lThreadSnapHandle := INVALID_HANDLE_VALUE;
      try
        lThreadSnapHandle := CreateToolhelp32Snapshot(TH32CS_SNAPALL, 0);
        if lThreadSnapHandle = INVALID_HANDLE_VALUE then
          Exit;

        lThreadEntry := default(THREADENTRY32);
        lThreadEntry.dwSize := SizeOf(THREADENTRY32);

        if not Thread32First(lThreadSnapHandle, lThreadEntry) then
          Exit;
        repeat
          if fProcessId <> lThreadEntry.th32OwnerProcessID then
            Continue;

          lThreadHandle :=OpenThread(THREAD_SUSPEND_RESUME, False, lThreadEntry.th32ThreadID);
          if lThreadHandle > 0 then
          begin
            if Winapi.Windows.SuspendThread(lThreadHandle) <> TWindowsProcessTools.DWORD_MAXVALUE then
            begin
              ProcessThreads.Add(lThreadHandle);
            end
            else
            begin
              TWindowsProcessTools.CloseThisHandle(lThreadHandle);
            end;
          end;
        until not Thread32Next(lThreadSnapHandle, lThreadEntry);
      finally
        TWindowsProcessTools.CloseThisHandle(lThreadSnapHandle);
      end;
    end
    else
    begin
      fLastError := Winapi.Windows.GetLastError;
    end;
  finally
    CriticalSection.Leave;
  end;
end;

{ TWindowsProcessRepository }

class constructor TWindowsProcessRepository.ClassCreate;
begin
  fCriticalSection := TCriticalSection.Create;
end;

class destructor TWindowsProcessRepository.ClassDestroy;
begin
  fInstance.Free;
  fCriticalSection.Free;
end;

class function TWindowsProcessRepository.GetInstance: TWindowsProcessRepository;
begin
  fCriticalSection.Enter;
  try
    if not Assigned(fInstance) then
      fInstance := TWindowsProcessRepository.Create;
    Result := fInstance;
  finally
    fCriticalSection.Leave;
  end;
end;

constructor TWindowsProcessRepository.Create;
begin
  inherited Create;
  fDictionaryCriticalSection := TCriticalSection.Create;
  fDictionary := TObjectDictionary<TObject,TWindowsProcessBase>.Create([doOwnsKeys]);
end;

destructor TWindowsProcessRepository.Destroy;
begin
  fDictionary.Free;
  fDictionaryCriticalSection.Free;
  inherited;
end;

function TWindowsProcessRepository.Add(const aValue: TWindowsProcessBase): TObject;
begin
  fDictionaryCriticalSection.Enter;
  try
    Result := TObject.Create;
    fDictionary.Add(Result, aValue);
  finally
    fDictionaryCriticalSection.Leave;
  end;
end;

procedure TWindowsProcessRepository.Remove(const aKey: TObject);
var lEntry: TWindowsProcessBase;
begin
  fDictionaryCriticalSection.Enter;
  try
    if fDictionary.TryGetValue(aKey, lEntry) then
    begin
      lEntry.CriticalSection.Enter;
      try
        fDictionary.Remove(aKey);
      finally
        lEntry.CriticalSection.Leave;
      end;
    end;
  finally
    fDictionaryCriticalSection.Leave;
  end;
end;

function TWindowsProcessRepository.TryGetValue(const aKey: TObject; out aValue: TWindowsProcessBase): Boolean;
begin
  fDictionaryCriticalSection.Enter;
  try
    Result := fDictionary.TryGetValue(aKey, aValue);
  finally
    fDictionaryCriticalSection.Leave;
  end;
end;

end.
