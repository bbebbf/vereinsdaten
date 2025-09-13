unit unExporter.Params.UnitMember;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unParamsDlg, Vcl.StdCtrls, Vcl.ExtCtrls, ParamsProvider,
  Exporter.UnitMembers.Types;

type
  TfmExporterParamsUnitMember = class(TfmParamsDlg, IParamsProvider<TExporterUnitMembersParams>)
    rbAllUnits: TRadioButton;
    rbAllCheckedUnits: TRadioButton;
    rbSelectedUnitDetails: TRadioButton;
  strict private
    fSelectUnitIdForDetails: UInt32;
    function GetParams(const aParams: TExporterUnitMembersParams): TExporterUnitMembersParams;
    procedure SetParams(const aParams: TExporterUnitMembersParams);
    function ShouldBeExported(const aParams: TExporterUnitMembersParams): Boolean;
  end;

implementation

uses UnitMapper;

{$R *.dfm}

{ TfmExporterParamsUnitMember }

function TfmExporterParamsUnitMember.GetParams(const aParams: TExporterUnitMembersParams): TExporterUnitMembersParams;
begin
  Result := aParams;
  if rbSelectedUnitDetails.Checked then
  begin
    Result.ExportOneUnitDetails := fSelectUnitIdForDetails;
  end
  else if rbAllUnits.Checked then
  begin
    SetLength(Result.CheckedUnitIds, 0);
  end;
end;

procedure TfmExporterParamsUnitMember.SetParams(const aParams: TExporterUnitMembersParams);
begin
  rbAllUnits.Checked := True;
  var lCheckedCount := Length(aParams.CheckedUnitIds);
  if lCheckedCount > 0 then
  begin
    rbAllCheckedUnits.Enabled := True;
    rbAllCheckedUnits.Caption := 'Ausgewählte ' + IntToStr(lCheckedCount) + ' Einheit(en) exportieren';
  end
  else
  begin
    rbAllCheckedUnits.Enabled := False;
  end;

  fSelectUnitIdForDetails := aParams.SelectedUnitId;
  if (fSelectUnitIdForDetails = 0) and (lCheckedCount = 1) then
    fSelectUnitIdForDetails := aParams.CheckedUnitIds[0];

  if fSelectUnitIdForDetails > 0 then
  begin
    rbSelectedUnitDetails.Enabled := True;
    rbSelectedUnitDetails.Caption := 'Ausgewählte Einheit "' +
      TUnitMapper.Instance.Data.Data.GetAllEntries.GetStringById(fSelectUnitIdForDetails, '???') +
      '" exportieren mit Details';
  end
  else
  begin
    rbSelectedUnitDetails.Enabled := False;
  end;
end;

function TfmExporterParamsUnitMember.ShouldBeExported(const aParams: TExporterUnitMembersParams): Boolean;
begin
  Result := aParams.ExportOneUnitDetails = 0;
end;

end.
