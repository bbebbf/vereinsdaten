unit Report.MemberUnits.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Members.Types, Report.Base.Printout;

type
  TfmReportMemberUnitsPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterMembersParams>)
    bdColumnHeader: TRLBand;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rdUnitname: TRLDBText;
    rdRolename: TRLDBText;
    rdPersonid: TRLDBText;
    rdUnitDivider: TRLDraw;
    lbStatus: TLabel;
    rtStatus: TRLDBText;
    rdInactiveInfo: TRLLabel;
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdRolenameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rtStatusBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    fParams: TExporterMembersParams;
    fPreviousPersonId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    fDefaultDetailHeight: Integer;
    procedure SetParams(const aParams: TExporterMembersParams);
  strict protected
    function GetReportTitle: string; override;
    procedure DoBeforePrint; override;
  end;

implementation

uses Vdm.Globals, StringTools, Exporter.Params.Tools;

{$R *.dfm}

{ TfmReportMemberUnits }

function TfmReportMemberUnitsPrintout.GetReportTitle: string;
begin
  Result := 'Personen und Einheiten';
end;

procedure TfmReportMemberUnitsPrintout.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lActiveRecordInfo := default(TActiveRecordInfo);
  lActiveRecordInfo.Active := rdUnitname.DataSet.FieldByName('person_active').AsBoolean;
  if lActiveRecordInfo.Active then
    rdPersonname.Font.Style := []
  else
    rdPersonname.Font.Style := [TFontStyle.fsStrikeOut];

  lActiveRecordInfo := default(TActiveRecordInfo);
  fParams.Units.State.GetActiveRecordInfo(rdPersonname.DataSet, lActiveRecordInfo);
  fParams.MembersState.GetActiveRecordInfo(rdPersonname.DataSet, lActiveRecordInfo, 'Verbindung');

  if lActiveRecordInfo.Active then
    rdUnitname.Font.Style := []
  else
    rdUnitname.Font.Style := [TFontStyle.fsStrikeOut];

  rdInactiveInfo.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfo.Caption := lActiveRecordInfo.InactiveInfoStr;
  if not rdInactiveInfo.Visible then
    bdDetail.Height := fDefaultDetailHeight;

  if fOneUnitPerPage then
  begin
    if not fNewPageStarted and (rdPersonid.Field.AsLargeInt <> fPreviousPersonId) then
    begin
      bdDetail.FGreenBarFlag := False;
      bdDetail.PageBreaking := pbBeforePrint
    end
    else
    begin
      bdDetail.PageBreaking := pbNone;
    end;
  end;
end;

procedure TfmReportMemberUnitsPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousPersonId := rdPersonid.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportMemberUnitsPrintout.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId);
end;

procedure TfmReportMemberUnitsPrintout.rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId);
end;

procedure TfmReportMemberUnitsPrintout.rdRolenameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  PrintIt := rdRolename.DataSource.DataSet.FieldByName('mb_active').AsBoolean;
end;

procedure TfmReportMemberUnitsPrintout.DoBeforePrint;
begin
  inherited;
  fPreviousPersonId := 0;
  fDefaultDetailHeight :=  (2 * rdUnitname.Top) + rdUnitname.Height;
end;

procedure TfmReportMemberUnitsPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportMemberUnitsPrintout.rtStatusBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  PrintIt := rtStatus.Visible and (fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId));
  if PrintIt then
    AText := TStringTools.Combine(rtStatus.DataSource.DataSet.FieldByName('person_external_e').AsString,
      ' ', rtStatus.DataSource.DataSet.FieldByName('person_inactive_i').AsString);
end;

procedure TfmReportMemberUnitsPrintout.SetParams(const aParams: TExporterMembersParams);
begin
  fParams := aParams;
  var lFilterInfo := GetPersonInclusionInfo(aParams.Persons.IncludeInactive, aParams.Persons.IncludeExternal);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.MembersState.GetReadableCondition);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.Units.State.GetReadableCondition);

  SetFilterInfo(lFilterInfo);

  lbStatus.Visible := aParams.Persons.IncludeInactive or aParams.Persons.IncludeExternal;
  rtStatus.Visible := lbStatus.Visible;
end;

end.
