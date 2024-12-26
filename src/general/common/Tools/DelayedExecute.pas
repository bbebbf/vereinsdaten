unit DelayedExecute;

interface

uses System.Classes, System.SyncObjs;

type
  TDelayedAction<T> = reference to procedure(const aParameter: T);

  TDelayedWorker<T> = class(TThread)
  strict private
    fCriticalSection: TCriticalSection;
    fWaitEvent: TLightweightEvent;
    fDelayMilliseconds: Integer;
    fAction: TDelayedAction<T>;
    fData: T;
    function TryGetData(out aData: T): Boolean;
  strict protected
    procedure Execute; override;
  public
    constructor Create(const aAction: TDelayedAction<T>; const aDelayMilliseconds: Integer);
    destructor Destroy; override;
    procedure SetData(const aData: T);
  end;

  TDelayedExecute<T> = class
  strict private
    fWorker: TDelayedWorker<T>;
  public
    constructor Create(const aAction: TDelayedAction<T>; const aDelayMilliseconds: Integer);
    destructor Destroy; override;
    procedure SetData(const aData: T);
  end;

implementation

{ TDelayedExecute<T> }

constructor TDelayedExecute<T>.Create(const aAction: TDelayedAction<T>; const aDelayMilliseconds: Integer);
begin
  inherited Create;
  fWorker := TDelayedWorker<T>.Create(aAction, aDelayMilliseconds);
end;

destructor TDelayedExecute<T>.Destroy;
begin
  fWorker.Terminate;
  fWorker.WaitFor;
  fWorker.Free;
  inherited;
end;

procedure TDelayedExecute<T>.SetData(const aData: T);
begin
  fWorker.SetData(aData);
end;

{ TDelayedWorker<T> }

constructor TDelayedWorker<T>.Create(const aAction: TDelayedAction<T>; const aDelayMilliseconds: Integer);
begin
  inherited Create;
  fCriticalSection := TCriticalSection.Create;
  fWaitEvent := TLightweightEvent.Create;
  fAction := aAction;
  fDelayMilliseconds := aDelayMilliseconds;
end;

destructor TDelayedWorker<T>.Destroy;
begin
  fWaitEvent.Free;
  fCriticalSection.Free;
  inherited;
end;

procedure TDelayedWorker<T>.Execute;
begin
  while not Terminated do
  begin
    var lData: T;
    if not TryGetData(lData) then
      Continue;
    if fWaitEvent.WaitFor(fDelayMilliseconds) = TWaitResult.wrSignaled then
      Continue;

    TThread.Queue(Self, procedure()
      begin
        fAction(lData);
      end
    );
  end;
end;

procedure TDelayedWorker<T>.SetData(const aData: T);
begin
  fCriticalSection.Enter;
  try
    fData := aData;
    fWaitEvent.SetEvent;
  finally
    fCriticalSection.Leave;
  end;
end;

function TDelayedWorker<T>.TryGetData(out aData: T): Boolean;
begin
  fCriticalSection.Enter;
  try
    Result := False;
    if fWaitEvent.IsSet then
    begin
      Result := True;
      aData := fData;
      fWaitEvent.ResetEvent;
    end;
  finally
    fCriticalSection.Leave;
  end;
end;

end.
