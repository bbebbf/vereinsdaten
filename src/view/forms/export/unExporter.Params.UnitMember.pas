unit unExporter.Params.UnitMember;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.Members.Types, unExporter.ActiveRangeParams;

type
  TfmExporterParamsUnitMember = class(TfmExporterParamsBase, IParamsProvider<TExporterMembersParams>)
    pnUnits: TPanel;
    fraParamsUnitsRange: TfraExporterActiveRangeParams;
    pnMembers: TPanel;
    fraParamsMembersRange: TfraExporterActiveRangeParams;
    pnPersons: TPanel;
    cbIncludeInactivePersons: TCheckBox;
    cbIncludeExternalPersons: TCheckBox;
    rbAllCheckedUnits: TRadioButton;
    cbIncludeOneTimeUnits: TCheckBox;
    cbIncludeExternalUnits: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure rbAllCheckedUnitsClick(Sender: TObject);
  strict private
    fSelectUnitIdForDetails: UInt32;
    fSelectUnitNameForDetails: string;
    procedure ParamsUnitsRangeChecked(Sender: TObject);
    function GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
    procedure SetParams(const aParams: TExporterMembersParams);
    function ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
  end;

implementation

uses DtoUnit;

{$R *.dfm}

{ TfmExporterParamsUnitMember }

procedure TfmExporterParamsUnitMember.FormCreate(Sender: TObject);
begin
  inherited;
  fraParamsUnitsRange.Initialize('Einheiten');
  fraParamsUnitsRange.OnOptionChecked := ParamsUnitsRangeChecked;
  fraParamsMembersRange.Initialize('Verbindungen');
end;

function TfmExporterParamsUnitMember.GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
begin
  Result := aParams;
  fraParamsUnitsRange.GetParams(Result.Units.State);
  if not rbAllCheckedUnits.Checked then
    Result.Units.CheckedUnitIds.Clear;
  Result.Units.SetDefaultKindOnly;
  if cbIncludeOneTimeUnits.Checked then
    Result.Units.IncludeOneTimeKind;
  if cbIncludeExternalUnits.Checked then
    Result.Units.IncludeExternalKind;
  fraParamsMembersRange.GetParams(Result.MembersState);
  Result.Persons.IncludeInactive := cbIncludeInactivePersons.Checked;
  Result.Persons.IncludeExternal := cbIncludeExternalPersons.Checked;
end;

procedure TfmExporterParamsUnitMember.ParamsUnitsRangeChecked(Sender: TObject);
begin
  rbAllCheckedUnits.Checked := False;
end;

procedure TfmExporterParamsUnitMember.rbAllCheckedUnitsClick(Sender: TObject);
begin
  inherited;
  fraParamsUnitsRange.UncheckAllOptions;
end;

procedure TfmExporterParamsUnitMember.SetParams(const aParams: TExporterMembersParams);
begin
  fraParamsUnitsRange.SetParams(aParams.Units.State);
  fraParamsMembersRange.SetParams(aParams.MembersState);
  cbIncludeInactivePersons.Checked := aParams.Persons.IncludeInactive;
  cbIncludeExternalPersons.Checked := aParams.Persons.IncludeExternal;
  rbAllCheckedUnits.Enabled := aParams.Units.CheckedUnitIds.Count > 0;
  rbAllCheckedUnits.Caption := 'Ausgewählte ' + IntToStr(aParams.Units.CheckedUnitIds.Count) + ' Einheit(en)';
  cbIncludeOneTimeUnits.Checked := TUnitKind.OneTimeKind in aParams.Units.Kinds;
  cbIncludeExternalUnits.Checked := TUnitKind.ExternalKind in aParams.Units.Kinds;
end;

function TfmExporterParamsUnitMember.ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
begin
  Result := True;
end;

end.
