unit ProgressIndicator;

interface

uses InterfacedBase, ProgressIndicatorIntf, ProgressUI;

type
  TProgressIndicator = class(TInterfacedBase, IProgressIndicator)
  strict private
    fUI: IProgressUI;
    fBeginCalls: Integer;
    procedure ProgressBegin(const aWorkCount: Integer; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer; const aStepText: string = '');
    procedure ProgressEnd;

    procedure HideUI;
  public
    constructor Create(const aUI: IProgressUI);
    destructor Destroy; override;
  end;

implementation

uses Vcl.Forms;

{ TProgressIndicator }

constructor TProgressIndicator.Create(const aUI: IProgressUI);
begin
  inherited Create;
  fUI := aUI;
end;

destructor TProgressIndicator.Destroy;
begin
  HideUI;
  inherited;
end;

procedure TProgressIndicator.ProgressBegin(const aWorkCount: Integer;
  const aText: string);
begin
  var lNewBeginCalls := AtomicIncrement(fBeginCalls);
  if lNewBeginCalls = 1 then
  begin
    fUI.PrimaryText := aText;
    fUI.SecondaryText := '';
    fUI.MaximalWork := aWorkCount;
    fUI.DoneWork := 0;
    fUI.Show;
  end
  else
  begin
    fUI.SecondaryText := aText;
  end;
  Application.ProcessMessages;
end;

procedure TProgressIndicator.ProgressEnd;
begin
  var lNewBeginCalls := AtomicDecrement(fBeginCalls);
  if lNewBeginCalls = 0 then
  begin
    fUI.Hide;
  end
  else
  begin
    fUI.SecondaryText := '';
  end;
  Application.ProcessMessages;
end;

procedure TProgressIndicator.ProgressStep(const aStepCount: Integer; const aStepText: string);
begin
end;

procedure TProgressIndicator.HideUI;
begin
  while fBeginCalls > 0 do
    ProgressEnd;
end;

end.
