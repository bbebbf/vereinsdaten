unit unExporter.Params.UnitMember;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.Members.Types;

type
  TfmExporterParamsUnitMember = class(TfmExporterParamsBase, IParamsProvider<TExporterMembersParams>)
    rbAllUnits: TRadioButton;
    rbAllCheckedUnits: TRadioButton;
    rbSelectedUnitDetails: TRadioButton;
  strict private
    fSelectUnitIdForDetails: UInt32;
    fSelectUnitNameForDetails: string;
    function GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
    procedure SetParams(const aParams: TExporterMembersParams);
    function ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
  strict protected
    function GetSuggestedExportFileName: string; override;
  end;

implementation

uses UnitMapper;

{$R *.dfm}

{ TfmExporterParamsUnitMember }

function TfmExporterParamsUnitMember.GetParams(const aParams: TExporterMembersParams): TExporterMembersParams;
begin
  Result := aParams;
  if rbSelectedUnitDetails.Checked then
  begin
    Result.Units.ExportOneUnitDetails := fSelectUnitIdForDetails;
  end
  else if rbAllUnits.Checked then
  begin
    SetLength(Result.Units.CheckedUnitIds, 0);
  end;
end;

function TfmExporterParamsUnitMember.GetSuggestedExportFileName: string;
begin
  if rbSelectedUnitDetails.Checked then
  begin
    Result := fSelectUnitNameForDetails + '_Personen';
  end
  else
  begin
    Result := inherited GetSuggestedExportFileName;
  end;
end;

procedure TfmExporterParamsUnitMember.SetParams(const aParams: TExporterMembersParams);
begin
  rbAllUnits.Checked := True;
  var lCheckedCount := Length(aParams.Units.CheckedUnitIds);
  if lCheckedCount > 0 then
  begin
    rbAllCheckedUnits.Enabled := True;
    rbAllCheckedUnits.Caption := 'Ausgewählte ' + IntToStr(lCheckedCount) + ' Einheit(en) exportieren';
  end
  else
  begin
    rbAllCheckedUnits.Enabled := False;
  end;

  fSelectUnitIdForDetails := aParams.Units.SelectedUnitId;
  if (fSelectUnitIdForDetails = 0) and (lCheckedCount = 1) then
    fSelectUnitIdForDetails := aParams.Units.CheckedUnitIds[0];

  if fSelectUnitIdForDetails > 0 then
  begin
    fSelectUnitNameForDetails := TUnitMapper.Instance.Data.Data.GetAllEntries.GetStringById(fSelectUnitIdForDetails, '???');
    rbSelectedUnitDetails.Visible := True;
    rbSelectedUnitDetails.Caption := 'Ausgewählte Einheit "'  + fSelectUnitNameForDetails + '" exportieren mit Details';
  end
  else
  begin
    rbSelectedUnitDetails.Visible := False;
  end;
end;

function TfmExporterParamsUnitMember.ShouldBeExported(const aParams: TExporterMembersParams): Boolean;
begin
  Result := aParams.Units.ExportOneUnitDetails = 0;
end;

end.
