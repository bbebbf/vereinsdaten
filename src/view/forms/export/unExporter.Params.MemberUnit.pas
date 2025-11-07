unit unExporter.Params.MemberUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.Members.Types, ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit;

type
  TfmExporterParamsMemberUnit = class(TfmExporterParamsBase, IParamsProvider<TExporterMembersParams>)
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
    function GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
    procedure SetParams(const aParams: TExporterMembersParams);
    function ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
  end;

implementation

uses System.DateUtils;

{$R *.dfm}

{ TfmExporterParamsMemberUnit }

function TfmExporterParamsMemberUnit.GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
begin
  Result := aParams;
  aParams.Persons.IncludeInactive := cbShowInactivePersons.Checked;
  aParams.Persons.IncludeExternal := cbShowExternalPersons.Checked;
  aParams.InactiveMembersButActiveUntil := 0;
  aParams.IncludeAllInactiveMembers := False;
  if rbInactiveMembersToo.Checked then
  begin
    if deInactiveButActiveUntil.ValidateValue and not deInactiveButActiveUntil.Value.Null then
    begin
      aParams.InactiveMembersButActiveUntil := deInactiveButActiveUntil.Value.Value.AsDate;
    end
    else
    begin
      aParams.IncludeAllInactiveMembers := True;
    end;
  end;
end;

procedure TfmExporterParamsMemberUnit.rbInactiveMembersTooClick(Sender: TObject);
begin
  inherited;
  lbInactiveButActiveUntil.Enabled := rbInactiveMembersToo.Checked;
  deInactiveButActiveUntil.Enabled := rbInactiveMembersToo.Checked;
end;

procedure TfmExporterParamsMemberUnit.SetParams(const aParams: TExporterMembersParams);
begin
end;

function TfmExporterParamsMemberUnit.ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
begin
  Result := True;
end;

end.
