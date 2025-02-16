unit ProgressIndicator;

interface

uses System.Generics.Collections, InterfacedBase, ProgressIndicatorIntf, ProgressUI;

type
  TProgressIndicatorTier = class
  public
    Text: string;
  end;

  TProgressIndicator = class(TInterfacedBase, IProgressIndicator)
  strict private
    fUI: IProgressUI;
    fTiers: TObjectStack<TProgressIndicatorTier>;
    procedure ProgressBegin(const aWorkCount: Integer; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer);
    procedure ProgressEnd;
    procedure ProgressText(const aText: string);
    function SuspendUI: IProgressUISuspendScope;

    function GetTopTier: TProgressIndicatorTier;
    procedure HideUI;
  public
    constructor Create(const aUI: IProgressUI);
    destructor Destroy; override;
  end;

implementation

uses Vcl.Forms;

type
  TProgressUISuspendScope = class(TInterfacedBase, IProgressUISuspendScope)
  strict private
    fUI: IProgressUI;
    fSuspended: Boolean;
    procedure Suspend;
    procedure Resume;
  public
    constructor Create(const aUI: IProgressUI);
    destructor Destroy; override;
  end;

{ TProgressIndicator }

constructor TProgressIndicator.Create(const aUI: IProgressUI);
begin
  inherited Create;
  fTiers := TObjectStack<TProgressIndicatorTier>.Create;
  fUI := aUI;
end;

destructor TProgressIndicator.Destroy;
begin
  HideUI;
  fTiers.Free;
  inherited;
end;

procedure TProgressIndicator.ProgressBegin(const aWorkCount: Integer;
  const aText: string);
begin
  var lTopTier := GetTopTier;

  var lNewTier := TProgressIndicatorTier.Create;
  lNewTier.Text := aText;
  fTiers.Push(lNewTier);

  if Assigned(lTopTier) then
  begin
    lTopTier.Text := fUI.SecondaryText;
    fUI.SecondaryText := aText;
    fUI.MaximalWork := fUI.MaximalWork + aWorkCount;
  end
  else
  begin
    fUI.PrimaryText := aText;
    fUI.SecondaryText := '';
    fUI.MaximalWork := aWorkCount;
    fUI.DoneWork := 0;
    fUI.Show;
  end;
  Application.ProcessMessages;
end;

procedure TProgressIndicator.ProgressEnd;
begin
  if fTiers.Count = 0 then
    Exit;

  fTiers.Pop;
  var lTopTier := GetTopTier;

  if Assigned(lTopTier) then
  begin
    fUI.SecondaryText := lTopTier.Text;
  end
  else
  begin
    fUI.Hide;
  end;
  Application.ProcessMessages;
end;

procedure TProgressIndicator.ProgressStep(const aStepCount: Integer);
begin
  if fTiers.Count = 0 then
    Exit;
  fUI.DoneWork := aStepCount;
end;

procedure TProgressIndicator.ProgressText(const aText: string);
begin
  if fTiers.Count = 0 then
    Exit;

  fUI.SecondaryText := aText;
end;

function TProgressIndicator.SuspendUI: IProgressUISuspendScope;
begin
  Result := TProgressUISuspendScope.Create(fUI);
end;

function TProgressIndicator.GetTopTier: TProgressIndicatorTier;
begin
  if fTiers.Count = 0 then
    Exit(nil);

  Result := fTiers.Peek;
end;

procedure TProgressIndicator.HideUI;
begin
  while fTiers.Count > 0 do
    ProgressEnd;
end;

{ TProgressUISuspendScope }

constructor TProgressUISuspendScope.Create(const aUI: IProgressUI);
begin
  inherited Create;
  fUI := aUI;
end;

destructor TProgressUISuspendScope.Destroy;
begin
  Resume;
  inherited;
end;

procedure TProgressUISuspendScope.Resume;
begin
  if fSuspended then
    fUI.Show;
end;

procedure TProgressUISuspendScope.Suspend;
begin
  fUI.Hide;
  fSuspended := True;
end;

end.
