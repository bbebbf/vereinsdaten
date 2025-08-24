unit unDatespanDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DatespanProvider, Nullable, Vcl.ComCtrls, Vcl.StdCtrls,
  ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, SimpleDate;

type
  TfmDatespanDlg = class(TForm, IDatespanProvider)
    btConfirm: TButton;
    btCancel: TButton;
    lbFromDate: TLabel;
    lbToDate: TLabel;
    sdFromDate: TDateEdit;
    sdToDate: TDateEdit;
    procedure sdFromDateValueChanged(Sender: TObject);
    procedure sdToDateValueChanged(Sender: TObject);
    procedure btConfirmClick(Sender: TObject);
    procedure sdFromDateExitQueryValidation(Sender: TObject;
      var aValidationResult: TValidationResult<SimpleDate.TSimpleDate>);
    procedure sdToDateExitQueryValidation(Sender: TObject;
      var aValidationResult: TValidationResult<SimpleDate.TSimpleDate>);
  private
    fFromDate: INullable<TDate>;
    fToDate: INullable<TDate>;

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
  var lDatespanIsValid := True;
  if ActiveControl = sdFromDate then
    lDatespanIsValid := sdFromDate.ValidateValue
  else if ActiveControl = sdToDate then
    lDatespanIsValid := sdToDate.ValidateValue;

  if lDatespanIsValid then
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

  if sdFromDate.Value.Null then
    Result.Reset
  else
    Result.Value := sdFromDate.Value.Value.AsDate;
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

  if sdToDate.Value.Null then
    Result.Reset
  else
    Result.Value := sdToDate.Value.Value.AsDate;
end;

function TfmDatespanDlg.ProvideDatespan: Boolean;
begin
  Result := ShowModal = mrOk;
end;

procedure TfmDatespanDlg.sdFromDateExitQueryValidation(Sender: TObject;
  var aValidationResult: TValidationResult<SimpleDate.TSimpleDate>);
begin
  aValidationResult.ValidationRequired := ActiveControl <> btCancel;
end;

procedure TfmDatespanDlg.sdFromDateValueChanged(Sender: TObject);
begin
  if sdFromDate.Value.Null or sdToDate.Value.Null then
    Exit;
  if sdFromDate.Value.Value > sdToDate.Value.Value then
    sdToDate.Value.Value := sdFromDate.Value.Value;
end;

procedure TfmDatespanDlg.sdToDateExitQueryValidation(Sender: TObject;
  var aValidationResult: TValidationResult<SimpleDate.TSimpleDate>);
begin
  aValidationResult.ValidationRequired := ActiveControl <> btCancel;
end;

procedure TfmDatespanDlg.sdToDateValueChanged(Sender: TObject);
begin
  if sdFromDate.Value.Null or sdToDate.Value.Null then
    Exit;
  if sdToDate.Value.Value < sdFromDate.Value.Value then
    sdFromDate.Value.Value := sdToDate.Value.Value;
end;

procedure TfmDatespanDlg.SetAllowedKinds(const aKinds: TDatespanKinds);
begin

end;

procedure TfmDatespanDlg.SetFromDate(const aFromDate: TDate);
begin
  sdFromDate.Value.Value := aFromDate;
end;

procedure TfmDatespanDlg.SetTitle(const aTitle: string);
begin
  Caption := aTitle;
end;

procedure TfmDatespanDlg.SetToDate(const aToDate: TDate);
begin
  sdToDate.Value.Value := aToDate;
end;

end.
