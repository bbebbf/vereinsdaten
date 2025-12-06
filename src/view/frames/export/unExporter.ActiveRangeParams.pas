unit unExporter.ActiveRangeParams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, ConstraintControls.ConstraintEdit,
  ConstraintControls.DateEdit, Exporter.Params.Tools;

type
  TfraExporterActiveRangeParams = class(TFrame)
    rbAllEntries: TRadioButton;
    rbActiveEntries: TRadioButton;
    rbInactiveEntriesOnly: TRadioButton;
    deActiveRangeFrom: TDateEdit;
    lbActiveRange: TLabel;
    deActiveRangeTo: TDateEdit;
    lbTo: TLabel;
    procedure deActiveRangeFromChange(Sender: TObject);
    procedure deActiveRangeToChange(Sender: TObject);
    procedure rbOptionClick(Sender: TObject);
  strict private
    fOnOptionChecked: TNotifyEvent;
  public
    procedure SetParams(const aParams: TActiveRangeParams);
    procedure GetParams(const aParams: TActiveRangeParams);
    procedure UncheckAllOptions;
    property OnOptionChecked: TNotifyEvent read fOnOptionChecked write fOnOptionChecked;
  end;

implementation

{$R *.dfm}

{ TfraExporterActiveRangeParams }

procedure TfraExporterActiveRangeParams.rbOptionClick(Sender: TObject);
begin
  deActiveRangeFrom.Enabled := Sender = rbActiveEntries;
  deActiveRangeTo.Enabled := Sender = rbActiveEntries;
  if Assigned(fOnOptionChecked) then
    fOnOptionChecked(Sender);
end;

procedure TfraExporterActiveRangeParams.deActiveRangeFromChange(Sender: TObject);
begin
  if deActiveRangeFrom.Value.Null or deActiveRangeTo.Value.Null then
    Exit;
  if deActiveRangeFrom.Value.Value > deActiveRangeTo.Value.Value then
    deActiveRangeTo.Value.Value := deActiveRangeFrom.Value.Value;
end;

procedure TfraExporterActiveRangeParams.deActiveRangeToChange(Sender: TObject);
begin
  if deActiveRangeFrom.Value.Null or deActiveRangeTo.Value.Null then
    Exit;
  if deActiveRangeTo.Value.Value < deActiveRangeFrom.Value.Value then
    deActiveRangeFrom.Value.Value := deActiveRangeTo.Value.Value;
end;

procedure TfraExporterActiveRangeParams.GetParams(const aParams: TActiveRangeParams);
begin
  aParams.ClearActiveRange;
  if rbAllEntries.Checked then
  begin
    aParams.Kind := TActiveRangeParamsKind.AllEntries;
  end
  else if rbActiveEntries.Checked then
  begin
    aParams.Kind := TActiveRangeParamsKind.ActiveEntries;
    if not deActiveRangeFrom.Value.Null then
      aParams.ActiveFrom := deActiveRangeFrom.Value.Value.AsDate;
    if not deActiveRangeTo.Value.Null then
      aParams.ActiveTo := deActiveRangeTo.Value.Value.AsDate;
  end
  else if rbInactiveEntriesOnly.Checked then
  begin
    aParams.Kind := TActiveRangeParamsKind.InactiveEntriesOnly;
  end
  else
  begin
    aParams.Kind := TActiveRangeParamsKind.Unknown;
  end;
end;

procedure TfraExporterActiveRangeParams.SetParams(const aParams: TActiveRangeParams);
begin
  rbAllEntries.Caption := 'Alle ' + aParams.EntityTitle;
  rbActiveEntries.Caption := 'Aktive ' + aParams.EntityTitle;
  rbInactiveEntriesOnly.Caption := 'Nur inaktive ' + aParams.EntityTitle;

  case aParams.Kind of
    TActiveRangeParamsKind.AllEntries:
      rbAllEntries.Checked := True;
    TActiveRangeParamsKind.ActiveEntries:
      rbActiveEntries.Checked := True;
    TActiveRangeParamsKind.InactiveEntriesOnly:
      rbInactiveEntriesOnly.Checked := True;
  end;
  if aParams.ActiveFromSet then
    deActiveRangeFrom.Value.Value := aParams.ActiveFrom
  else
    deActiveRangeFrom.Clear;
  if aParams.ActiveToSet then
    deActiveRangeTo.Value.Value := aParams.ActiveTo
  else
    deActiveRangeTo.Clear;
end;

procedure TfraExporterActiveRangeParams.UncheckAllOptions;
begin
  rbAllEntries.Checked := False;
  rbActiveEntries.Checked := False;
  rbInactiveEntriesOnly.Checked := False;
end;

end.
