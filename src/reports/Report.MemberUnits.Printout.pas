unit Report.MemberUnits.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Members.Types, Report.Base.Printout;

type
  TfmReportMemberUnitsPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterMembersParams>)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    lbTenantTitle: TLabel;
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
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    memFilterInfo: TRLMemo;
    lbStatus: TLabel;
    rtStatus: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdRolenameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rtStatusBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    fPreviousPersonId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    procedure SetParams(const aParams: TExporterMembersParams);
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses TenantReader, Vdm.Globals, StringTools;

{$R *.dfm}

{ TfmReportMemberUnits }

procedure TfmReportMemberUnitsPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportMemberUnitsPrintout.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
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

procedure TfmReportMemberUnitsPrintout.rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  if rdUnitname.DataSource.DataSet.FieldByName('mb_active').AsBoolean then
  begin
    rdUnitname.Font.Style := [];
  end
  else
  begin
    rdUnitname.Font.Style := [TFontStyle.fsStrikeOut];
    if not rdUnitname.DataSource.DataSet.FieldByName('mb_active_until').IsNull then
    begin
      AText := AText + ' (bis ' + FormatDateTime('c', rdUnitname.DataSource.DataSet.FieldByName('mb_active_until').AsDateTime) + ')';
    end;
  end;
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

procedure TfmReportMemberUnitsPrintout.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousPersonId := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
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
  var lFilterInfo := '';
  if aParams.Persons.IncludeInactive and aParams.Persons.IncludeExternal then
  begin
    lFilterInfo := 'Externe und inaktive Personen enthalten.';
  end
  else if aParams.Persons.IncludeInactive then
  begin
    lFilterInfo := 'Inaktive Personen enthalten.';
  end
  else if aParams.Persons.IncludeExternal then
  begin
    lFilterInfo := 'Externe Personen enthalten.';
  end;
  {
  if aParams.IncludeAllInactiveMembers then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Alle inaktive Verbindungen enthalten.');
  end
  else if aParams.InactiveMembersButActiveUntil > 0 then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Inaktive Verbindungen enthalten');
    lFilterInfo := lFilterInfo + ' (noch aktiv am ' + FormatDateTime('c', aParams.InactiveMembersButActiveUntil) + ').';
  end;
  }
  memFilterInfo.Lines.Text := lFilterInfo;
  memFilterInfo.Visible := Length(lFilterInfo) > 0;

  lbStatus.Visible := aParams.Persons.IncludeInactive or aParams.Persons.IncludeExternal;
  rtStatus.Visible := lbStatus.Visible;
end;

end.
