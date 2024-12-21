unit unProgressForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  ProgressIndicator;

type
  TfmProgressForm = class(TForm, IProgressIndicator)
    pnMain: TPanel;
    lbMaintext: TLabel;
    lbSteptext: TLabel;
    pbProgress: TProgressBar;
  private
  public
    constructor Create(AOwner: TComponent); override;
    procedure ProgressBegin(const aWorkCount: Integer; const aSteptextAvailable: Boolean; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer; const aStepText: string = '');
    procedure ProgressEnd;
  end;

implementation

{$R *.dfm}

{ TfmProgressForm }

constructor TfmProgressForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  if AOwner is TCustomForm then
  begin
    Position := TPosition.poOwnerFormCenter;
  end
  else
  begin
    Position := TPosition.poScreenCenter;
  end;
end;

procedure TfmProgressForm.ProgressBegin(const aWorkCount: Integer; const aSteptextAvailable: Boolean;
  const aText: string);
begin
  lbMaintext.Caption := aText;
  if aWorkCount > 0 then
  begin
    pbProgress.Max := aWorkCount;
    pbProgress.Min := 0;
    pbProgress.Position := 0;
    pbProgress.Visible := True;
  end
  else
  begin
    pbProgress.Visible := False;
  end;
  lbSteptext.Visible := aSteptextAvailable;
  Show;
  Application.ProcessMessages;
end;

procedure TfmProgressForm.ProgressEnd;
begin
  Hide;
  Application.ProcessMessages;
end;

procedure TfmProgressForm.ProgressStep(const aStepCount: Integer; const aStepText: string);
begin
  if pbProgress.Visible and (pbProgress.Position < pbProgress.Max) then
    pbProgress.Position := aStepCount;
  if lbSteptext.Visible then
    lbSteptext.Caption := aStepText;
  Application.ProcessMessages;
end;

end.
