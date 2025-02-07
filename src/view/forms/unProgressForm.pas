unit unProgressForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.ComCtrls,
  ProgressUI;

type
  TfmProgressForm = class(TForm, IProgressUI)
    pnMain: TPanel;
    lbPrimarytext: TLabel;
    lbSecondarytext: TLabel;
    pbProgress: TProgressBar;
  private
    function GetPrimaryText: string;
    procedure SetPrimaryText(const aValue: string);
    function GetSecondaryText: string;
    procedure SetSecondaryText(const aValue: string);
    function GetDoneWork: Integer;
    procedure SetDoneWork(const aValue: Integer);
    function GetMaxmimalWork: Integer;
    procedure SetMaximalWork(const aValue: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

{ TfmProgressForm }

constructor TfmProgressForm.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Position := TPosition.poScreenCenter;
end;

function TfmProgressForm.GetDoneWork: Integer;
begin
  Result := pbProgress.Position;
end;

function TfmProgressForm.GetPrimaryText: string;
begin
  Result := lbPrimarytext.Caption;
end;

function TfmProgressForm.GetMaxmimalWork: Integer;
begin
  Result := pbProgress.Max;
end;

function TfmProgressForm.GetSecondaryText: string;
begin
  Result := lbSecondarytext.Caption;
end;

procedure TfmProgressForm.SetDoneWork(const aValue: Integer);
begin
  pbProgress.Position := aValue;
end;

procedure TfmProgressForm.SetPrimaryText(const aValue: string);
begin
  lbPrimarytext.Caption := aValue;
end;

procedure TfmProgressForm.SetMaximalWork(const aValue: Integer);
begin
  pbProgress.Min := 0;
  pbProgress.Max := aValue;
  pbProgress.Visible := aValue > 0;
end;

procedure TfmProgressForm.SetSecondaryText(const aValue: string);
begin
  lbSecondarytext.Caption := aValue;
end;

end.
