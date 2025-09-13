unit unParamsDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, ValidatableValueControlsRegistry;

type
  TfmParamsDlg = class(TForm)
    pnBottom: TPanel;
    btOk: TButton;
    btCancel: TButton;
    procedure btCancelClick(Sender: TObject);
    procedure btOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  strict private
    fValidatableValueControlsRegistry: TValidatableValueControlsRegistry;
  strict protected
    function ProvideParams: Boolean;
    function ParamsValid: Boolean; virtual;
    property ValidatableValueControlsRegistry: TValidatableValueControlsRegistry read fValidatableValueControlsRegistry;
  public
  end;

implementation

{$R *.dfm}

{ TfmParamsDlg }

procedure TfmParamsDlg.btCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfmParamsDlg.btOkClick(Sender: TObject);
begin
  if not fValidatableValueControlsRegistry.ValidateValues then
    Exit;
  if not ParamsValid then
    Exit;

  ModalResult := mrOk;
end;

procedure TfmParamsDlg.FormCreate(Sender: TObject);
begin
  fValidatableValueControlsRegistry := TValidatableValueControlsRegistry.Create;
  fValidatableValueControlsRegistry.Form := Self;
  fValidatableValueControlsRegistry.CancelControl := btCancel;
end;

procedure TfmParamsDlg.FormDestroy(Sender: TObject);
begin
  fValidatableValueControlsRegistry.Free;
end;

function TfmParamsDlg.ParamsValid: Boolean;
begin
  Result := True;
end;

function TfmParamsDlg.ProvideParams: Boolean;
begin
  Result := ShowModal = mrOk;
end;

end.
