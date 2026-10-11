unit Report.UnitRoles.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Members.Types, Report.Base.Printout;

type
  TfmReportUnitRolesPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterMembersParams>)
    bdColumnHeader: TRLBand;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    bdDetail: TRLBand;
    rdRoleName: TRLDBText;
    rdPersonname: TRLDBText;
    rdUnitname: TRLDBText;
    rdRoleId: TRLDBText;
    rdDivider: TRLDraw;
    Label1: TLabel;
    RLDBText1: TRLDBText;
    rdInactiveInfoUnit: TRLLabel;
    rdInactiveInfo: TRLLabel;
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdRoleNameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fParams: TExporterMembersParams;
    fPreviousRoleId: UInt32;
    fNewPageStarted: Boolean;
    fDefaultDetailHeight: Integer;
    procedure SetParams(const aParams: TExporterMembersParams);
  strict protected
    function GetReportTitle: string; override;
    procedure DoBeforePrint; override;
  end;

implementation

uses Vdm.Globals, StringTools, Exporter.Params.Tools;

{$R *.dfm}

{ TfmReportUnitRoles }

procedure TfmReportUnitRolesPrintout.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lActiveRecordInfo := default(TActiveRecordInfo);
  fParams.Units.State.GetActiveRecordInfo(rdRoleName.DataSet, lActiveRecordInfo);

  if lActiveRecordInfo.Active then
    rdUnitname.Font.Style := []
  else
    rdUnitname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfoUnit.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfoUnit.Caption := lActiveRecordInfo.InactiveInfoStr;

  lActiveRecordInfo := default(TActiveRecordInfo);
  lActiveRecordInfo.Active := rdUnitname.DataSet.FieldByName('person_active').AsBoolean;
  fParams.MembersState.GetActiveRecordInfo(rdRoleName.DataSet, lActiveRecordInfo, 'Verbindung');
  if lActiveRecordInfo.Active then
    rdPersonname.Font.Style := []
  else
    rdPersonname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfo.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfo.Caption := lActiveRecordInfo.InactiveInfoStr;

  if not rdInactiveInfoUnit.Visible and not rdInactiveInfo.Visible then
    bdDetail.Height := fDefaultDetailHeight;
end;

function TfmReportUnitRolesPrintout.GetReportTitle: string;
begin
  Result := 'Rollen, Einheiten und Personen';
end;

procedure TfmReportUnitRolesPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousRoleId := rdRoleId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitRolesPrintout.rdDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdRoleId.Field.AsLargeInt <> fPreviousRoleId);
end;

procedure TfmReportUnitRolesPrintout.rdRoleNameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdRoleId.Field.AsLargeInt <> fPreviousRoleId);
end;

procedure TfmReportUnitRolesPrintout.DoBeforePrint;
begin
  inherited;
  fPreviousRoleId := 0;
  fDefaultDetailHeight :=  (2 * rdUnitname.Top) + rdUnitname.Height;
end;

procedure TfmReportUnitRolesPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportUnitRolesPrintout.SetParams(const aParams: TExporterMembersParams);
begin
  fParams := aParams;
  var lFilterInfo := GetPersonInclusionInfo(aParams.Persons.IncludeInactive, aParams.Persons.IncludeExternal);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.MembersState.GetReadableCondition);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.Units.State.GetReadableCondition);

  SetFilterInfo(lFilterInfo);
end;

end.
