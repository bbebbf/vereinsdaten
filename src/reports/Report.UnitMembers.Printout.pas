unit Report.UnitMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  SqlConnection, Exporter.Types, Exporter.Members.Types, Report.Base.Printout;

type
  TfmReportUnitMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterMembersParams>)
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
    rdUnitname: TRLDBText;
    rdPersonname: TRLDBText;
    RLDBText3: TRLDBText;
    rdUinitId: TRLDBText;
    rdUnitDivider: TRLDraw;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    Label1: TLabel;
    rdUnitDataConfirmed: TRLDBText;
    rdMemberCount: TRLDBText;
    Label2: TLabel;
    rdUnitKind: TRLDBText;
    memFilterInfo: TRLMemo;
    rdInactiveInfo: TRLLabel;
    rdInactiveInfoUnit: TRLLabel;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fParams: TExporterMembersParams;
    fPreviousUnitId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    fDefaultDetailHeight: Integer;
    procedure SetParams(const aParams: TExporterMembersParams);
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses TenantReader, Vdm.Globals, DtoUnit, StringTools, Exporter.Params.Tools;

{$R *.dfm}

{ TfmReportUnitMembers }

procedure TfmReportUnitMembersPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportUnitMembersPrintout.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lActiveRecordInfo := default(TActiveRecordInfo);
  fParams.Units.State.GetActiveRecordInfo(rdUnitname.DataSet, lActiveRecordInfo);
  if lActiveRecordInfo.Active then
    rdUnitname.Font.Style := []
  else
    rdUnitname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfoUnit.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfoUnit.Caption := lActiveRecordInfo.InactiveInfoStr;

  lActiveRecordInfo := default(TActiveRecordInfo);
  lActiveRecordInfo.Active := rdUnitname.DataSet.FieldByName('person_active').AsBoolean;
  fParams.MembersState.GetActiveRecordInfo(rdUnitname.DataSet, lActiveRecordInfo, 'Verbindung');
  if lActiveRecordInfo.Active then
    rdPersonname.Font.Style := []
  else
    rdPersonname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfo.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfo.Caption := lActiveRecordInfo.InactiveInfoStr;

  if not rdInactiveInfoUnit.Visible and not rdInactiveInfo.Visible then
    bdDetail.Height := fDefaultDetailHeight;

  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  if fOneUnitPerPage then
  begin
    if not fNewPageStarted and lUnitBreak then
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

procedure TfmReportUnitMembersPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousUnitId := rdUinitId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitMembersPrintout.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
end;

procedure TfmReportUnitMembersPrintout.rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
  if (Sender = rdUnitname) and (rdMemberCount.Field.AsInteger > 5) then
  begin
    AText := AText + ' (' + IntToStr(rdMemberCount.Field.AsInteger) + ' Pers.)';
  end
  else if Sender = rdUnitKind then
  begin
    AText := UnitKindToStrShort(TUnitKind(rdUnitKind.Field.AsInteger));
  end
  else if Sender = rdUnitDataConfirmed then
  begin
    AText := TVdmGlobals.GetDateAsString(rdUnitDataConfirmed.Field.AsDateTime);
  end;
end;

procedure TfmReportUnitMembersPrintout.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousUnitId := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  fDefaultDetailHeight := (2 * rdUnitname.Top) + rdUnitname.Height;
end;

procedure TfmReportUnitMembersPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportUnitMembersPrintout.SetParams(const aParams: TExporterMembersParams);
begin
  fParams := aParams;
  var lFilterInfo := '';
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.Units.State.GetReadableCondition);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.MembersState.GetReadableCondition);
  if aParams.Persons.IncludeInactive and aParams.Persons.IncludeExternal then
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Externe und inaktive Personen enthalten.')
  else if aParams.Persons.IncludeInactive then
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Inaktive Personen enthalten.')
  else if aParams.Persons.IncludeExternal then
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Externe Personen enthalten.');

  memFilterInfo.Lines.Text := lFilterInfo;
  memFilterInfo.Visible := Length(lFilterInfo) > 0;
end;

end.
