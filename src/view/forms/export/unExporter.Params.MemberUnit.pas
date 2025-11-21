unit unExporter.Params.MemberUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.Members.Types, ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, unExporter.ActiveRangeParams;

type
  TfmExporterParamsMemberUnit = class(TfmExporterParamsBase, IParamsProvider<TExporterMembersParams>)
    pnPersons: TPanel;
    cbIncludeInactivePersons: TCheckBox;
    cbIncludeExternalPersons: TCheckBox;
    pnMembers: TPanel;
    fraParamsMembersRange: TfraExporterActiveRangeParams;
    pnUnits: TPanel;
    fraParamsUnitsRange: TfraExporterActiveRangeParams;
    cbIncludeOneTimeUnits: TCheckBox;
    cbIncludeExternalUnits: TCheckBox;
    procedure FormCreate(Sender: TObject);
  strict private
    fSelectUnitIdForDetails: UInt32;
    fSelectUnitNameForDetails: string;
    function GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
    procedure SetParams(const aParams: TExporterMembersParams);
    function ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
  end;

implementation

uses DtoUnit;

{$R *.dfm}

{ TfmExporterParamsMemberUnit }

procedure TfmExporterParamsMemberUnit.FormCreate(Sender: TObject);
begin
  inherited;
  fraParamsMembersRange.Initialize('Verbindungen');
  fraParamsUnitsRange.Initialize('Einheiten');
end;

function TfmExporterParamsMemberUnit.GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
begin
  Result := aParams;
  Result.Persons.IncludeInactive := cbIncludeInactivePersons.Checked;
  Result.Persons.IncludeExternal := cbIncludeExternalPersons.Checked;
  fraParamsMembersRange.GetParams(Result.MembersState);
  fraParamsUnitsRange.GetParams(Result.Units.State);
  Result.Units.SetDefaultKindOnly;
  if cbIncludeOneTimeUnits.Checked then
    Result.Units.IncludeOneTimeKind;
  if cbIncludeExternalUnits.Checked then
    Result.Units.IncludeExternalKind;
end;

procedure TfmExporterParamsMemberUnit.SetParams(const aParams: TExporterMembersParams);
begin
  cbIncludeInactivePersons.Checked := aParams.Persons.IncludeInactive;
  cbIncludeExternalPersons.Checked := aParams.Persons.IncludeExternal;
  fraParamsMembersRange.SetParams(aParams.MembersState);
  fraParamsUnitsRange.SetParams(aParams.Units.State);
  cbIncludeOneTimeUnits.Checked := TUnitKind.OneTimeKind in aParams.Units.Kinds;
  cbIncludeExternalUnits.Checked := TUnitKind.ExternalKind in aParams.Units.Kinds;
end;

function TfmExporterParamsMemberUnit.ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
begin
  Result := True;
end;

end.
