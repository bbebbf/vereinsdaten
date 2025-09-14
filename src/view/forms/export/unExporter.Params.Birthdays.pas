unit unExporter.Params.Birthdays;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls,
  ParamsProvider, Exporter.Birthdays.Types, ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit;
type
  TfmExporterParamsBirthdays = class(TfmExporterParamsBase, IParamsProvider<TExporterBirthdaysParams>)
    deFromDate: TDateEdit;
    deToDate: TDateEdit;
    lbFrom: TLabel;
    lbTo: TLabel;
    cbConsiderBirthdaylistFlag: TCheckBox;
    rgOrderBy: TRadioGroup;
    procedure deFromDateValueChanged(Sender: TObject);
    procedure deToDateValueChanged(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  strict private
    function GetParams(const aParams: TExporterBirthdaysParams): TExporterBirthdaysParams;
    procedure SetParams(const aParams: TExporterBirthdaysParams);
    function ShouldBeExported(const aParams: TExporterBirthdaysParams): Boolean;
  end;

implementation

{$R *.dfm}

{ TfmExporterParamsBirthdays }

procedure TfmExporterParamsBirthdays.deFromDateValueChanged(Sender: TObject);
begin
  inherited;
  if deFromDate.Value.Null or deToDate.Value.Null then
    Exit;
  if deFromDate.Value.Value > deToDate.Value.Value then
    deToDate.Value.Value := deFromDate.Value.Value;
end;

procedure TfmExporterParamsBirthdays.deToDateValueChanged(Sender: TObject);
begin
  if deFromDate.Value.Null or deToDate.Value.Null then
    Exit;
  if deToDate.Value.Value < deFromDate.Value.Value then
    deFromDate.Value.Value := deToDate.Value.Value;
end;

procedure TfmExporterParamsBirthdays.FormCreate(Sender: TObject);
begin
  inherited;
  ValidatableValueControlsRegistry.RegisterControl(deFromDate);
  ValidatableValueControlsRegistry.RegisterControl(deToDate);
end;

function TfmExporterParamsBirthdays.GetParams(const aParams: TExporterBirthdaysParams): TExporterBirthdaysParams;
begin
  Result := aParams;
  Result.FromDate := deFromDate.Value.Value.AsDate;
  Result.ToDate := deToDate.Value.Value.AsDate;
  Result.ConsiderBirthdaylistFlag := cbConsiderBirthdaylistFlag.Checked;
  Result.SortedByName := rgOrderBy.ItemIndex = 1;
end;

procedure TfmExporterParamsBirthdays.SetParams(const aParams: TExporterBirthdaysParams);
begin
  deFromDate.Value.Value := aParams.FromDate;
  deToDate.Value.Value := aParams.ToDate;
  cbConsiderBirthdaylistFlag.Checked := aParams.ConsiderBirthdaylistFlag;
  if aParams.SortedByName then
    rgOrderBy.ItemIndex := 1
  else
    rgOrderBy.ItemIndex := 0;
end;

function TfmExporterParamsBirthdays.ShouldBeExported(const aParams: TExporterBirthdaysParams): Boolean;
begin
  Result := True;
end;

end.
