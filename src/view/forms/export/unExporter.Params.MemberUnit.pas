unit unExporter.Params.MemberUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.MemberUnits.Types, ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit;

type
  TfmExporterParamsMemberUnit = class(TfmExporterParamsBase, IParamsProvider<TExporterMemberUnitsParams>)
    rbActiveMembersOnly: TRadioButton;
    rbInactiveMembersToo: TRadioButton;
    lbInactiveButActiveUntil: TLabel;
    deInactiveButActiveUntil: TDateEdit;
    cbShowInactivePersons: TCheckBox;
    cbShowExternalPersons: TCheckBox;
    procedure rbInactiveMembersTooClick(Sender: TObject);
  strict private
    fSelectUnitIdForDetails: UInt32;
    fSelectUnitNameForDetails: string;
    function GetParams(const aParams: TExporterMemberUnitsParams): TExporterMemberUnitsParams;
    procedure SetParams(const aParams: TExporterMemberUnitsParams);
    function ShouldBeExported(const aParams: TExporterMemberUnitsParams): Boolean;
  end;

implementation

uses System.DateUtils;

{$R *.dfm}

{ TfmExporterParamsMemberUnit }

function TfmExporterParamsMemberUnit.GetParams(const aParams: TExporterMemberUnitsParams): TExporterMemberUnitsParams;
begin
  Result := aParams;
  aParams.IncludeInactivePersons := cbShowInactivePersons.Checked;
  aParams.IncludeExternalPersons := cbShowExternalPersons.Checked;
  aParams.InactiveButActiveUntil := 0;
  aParams.IncludeAllInactiveEntries := False;
  if rbInactiveMembersToo.Checked then
  begin
    if deInactiveButActiveUntil.ValidateValue and not deInactiveButActiveUntil.Value.Null then
    begin
      aParams.InactiveButActiveUntil := deInactiveButActiveUntil.Value.Value.AsDate;
    end
    else
    begin
      aParams.IncludeAllInactiveEntries := True;
    end;
  end;
end;

procedure TfmExporterParamsMemberUnit.rbInactiveMembersTooClick(Sender: TObject);
begin
  inherited;
  lbInactiveButActiveUntil.Enabled := rbInactiveMembersToo.Checked;
  deInactiveButActiveUntil.Enabled := rbInactiveMembersToo.Checked;
end;

procedure TfmExporterParamsMemberUnit.SetParams(const aParams: TExporterMemberUnitsParams);
begin
end;

function TfmExporterParamsMemberUnit.ShouldBeExported(const aParams: TExporterMemberUnitsParams): Boolean;
begin
  Result := True;
end;

end.
