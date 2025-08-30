unit unDatespanDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DatespanProvider, Nullable, Vcl.ComCtrls, Vcl.StdCtrls,
  ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, ValidatableValueControlsRegistry;

type
  TfmDatespanDlg = class(TForm, IDatespanProvider)
    btConfirm: TButton;
    btCancel: TButton;
    lbFromDate: TLabel;
    lbToDate: TLabel;
    deFromDate: TDateEdit;
    deToDate: TDateEdit;
    procedure deFromDateValueChanged(Sender: TObject);
    procedure deToDateValueChanged(Sender: TObject);
    procedure btConfirmClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    fFromDate: INullable<TDate>;
    fToDate: INullable<TDate>;
    fValidatableValueControlsRegistry: TValidatableValueControlsRegistry;

    function ProvideDatespan: Boolean;
    function GetTitle: string;
    procedure SetTitle(const aTitle: string);
    function GetAllowedKinds: TDatespanKinds;
    procedure SetAllowedKinds(const aKinds: TDatespanKinds);
    function GetFromDate: INullable<TDate>;
    procedure SetFromDate(const aFromDate: TDate);
    function GetToDate: INullable<TDate>;
    procedure SetToDate(const aToDate: TDate);
  public
  end;

implementation

{$R *.dfm}

uses System.DateUtils;

{ TfmDatespanDlg }

procedure TfmDatespanDlg.btConfirmClick(Sender: TObject);
begin
  if not fValidatableValueControlsRegistry.ValidateValues then
    Exit;

  ModalResult := mrOk;
end;

function TfmDatespanDlg.GetAllowedKinds: TDatespanKinds;
begin
  Result := [];
end;

function TfmDatespanDlg.GetFromDate: INullable<TDate>;
begin
  if not Assigned(fFromDate) then
    fFromDate := TNullable<TDate>.Create;
  Result := fFromDate;

  if deFromDate.Value.Null then
    Result.Reset
  else
    Result.Value := deFromDate.Value.Value.AsDate;
end;

function TfmDatespanDlg.GetTitle: string;
begin
  Result := Caption;
end;

function TfmDatespanDlg.GetToDate: INullable<TDate>;
begin
  if not Assigned(fToDate) then
    fToDate := TNullable<TDate>.Create;
  Result := fToDate;

  if deToDate.Value.Null then
    Result.Reset
  else
    Result.Value := deToDate.Value.Value.AsDate;
end;

function TfmDatespanDlg.ProvideDatespan: Boolean;
begin
  Result := ShowModal = mrOk;
end;

procedure TfmDatespanDlg.deFromDateValueChanged(Sender: TObject);
begin
  if deFromDate.Value.Null or deToDate.Value.Null then
    Exit;
  if deFromDate.Value.Value > deToDate.Value.Value then
    deToDate.Value.Value := deFromDate.Value.Value;
end;

procedure TfmDatespanDlg.deToDateValueChanged(Sender: TObject);
begin
  if deFromDate.Value.Null or deToDate.Value.Null then
    Exit;
  if deToDate.Value.Value < deFromDate.Value.Value then
    deFromDate.Value.Value := deToDate.Value.Value;
end;

procedure TfmDatespanDlg.FormCreate(Sender: TObject);
begin
  fValidatableValueControlsRegistry := TValidatableValueControlsRegistry.Create;
  fValidatableValueControlsRegistry.Form := Self;
  fValidatableValueControlsRegistry.CancelControl := btCancel;

  fValidatableValueControlsRegistry.RegisterControl(deFromDate);
  fValidatableValueControlsRegistry.RegisterControl(deToDate);
end;

procedure TfmDatespanDlg.FormDestroy(Sender: TObject);
begin
  fValidatableValueControlsRegistry.Free;
end;

procedure TfmDatespanDlg.SetAllowedKinds(const aKinds: TDatespanKinds);
begin

end;

procedure TfmDatespanDlg.SetFromDate(const aFromDate: TDate);
begin
  deFromDate.Value.Value := aFromDate;
end;

procedure TfmDatespanDlg.SetTitle(const aTitle: string);
begin
  Caption := aTitle;
end;

procedure TfmDatespanDlg.SetToDate(const aToDate: TDate);
begin
  deToDate.Value.Value := aToDate;
end;

end.
