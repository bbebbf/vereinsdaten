unit Report.MemberUnits.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Persons.Types, Report.Base.Printout;

type
  TfmReportMemberUnitsPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterPersonsParams>)
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
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    rdPersonid: TRLDBText;
    rdUnitDivider: TRLDraw;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    lbSpecialPersonsInfo: TRLLabel;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fPreviousPersonId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    procedure SetParams(const aParams: TExporterPersonsParams);
    procedure DoExport(const aDataSet: ISqlDataSet);
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportMemberUnits }

procedure TfmReportMemberUnitsPrintout.DoExport(const aDataSet: ISqlDataSet);
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

procedure TfmReportMemberUnitsPrintout.rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId);
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

procedure TfmReportMemberUnitsPrintout.SetParams(const aParams: TExporterPersonsParams);
begin
  lbSpecialPersonsInfo.Visible := aParams.ShowInactivePersons or aParams.ShowExternalPersons;
  if aParams.ShowInactivePersons and aParams.ShowExternalPersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Externe und inaktive Personen enthalten.';
  end
  else if aParams.ShowInactivePersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Inaktive Personen enthalten.';
  end
  else if aParams.ShowExternalPersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Externe Personen enthalten.';
  end;
end;

end.
