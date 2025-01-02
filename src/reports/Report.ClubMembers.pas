unit Report.ClubMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, SqlConnection, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmReportClubMembers = class(TForm)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdDetail: TRLBand;
    RLDBText1: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    RLDBText4: TRLDBText;
    bdColumnHeader: TRLBand;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RLDBText5: TRLDBText;
    Label8: TLabel;
    Label9: TLabel;
    RLDBText6: TRLDBText;
    rdInactive: TRLDBText;
    Label7: TLabel;
    RLDBText8: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbTenantTitle: TLabel;
    bdSummary: TRLBand;
    lbActiveInactive: TLabel;
    lbAppTitle: TLabel;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdInactiveAfterPrint(Sender: TObject);
    procedure bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
    fActiveCounter: Integer;
    fInactiveCounter: Integer;
  public
    { Public-Deklarationen }
    constructor Create(const aConnection: ISqlConnection); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportClubMembers }

constructor TfmReportClubMembers.Create(const aConnection: ISqlConnection);
begin
  inherited Create(nil);
  fConnection := aConnection;
end;

procedure TfmReportClubMembers.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportClubMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fActiveCounter := 0;
  fInactiveCounter := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT cm.*, pn.person_name, p.person_birthday, sa.address_title' +
    ', IFNULL(DATE_FORMAT(cm.clmb_enddate, ''%d.%m.%Y''), cm.clmb_enddate_str) AS clmb_enddate_calculated' +
    ', IF(cm.clmb_active, null, "X") AS clmb_inactive' +
    ' FROM clubmembership AS cm' +
    ' INNER JOIN person AS p ON p.person_id = cm.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = cm.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = cm.person_id' +
    ' LEFT JOIN vw_select_address AS sa ON sa.adr_id = pa.adr_id' +
    ' ORDER BY cm.clmb_number, pn.person_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
end;

procedure TfmReportClubMembers.bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbActiveInactive.Caption := 'Aktive: ' + IntToStr(fActiveCounter) + ' / Inaktive: ' + IntToStr(fInactiveCounter);
end;

procedure TfmReportClubMembers.rdInactiveAfterPrint(Sender: TObject);
begin
  if Length(rdInactive.Field.AsString) = 0 then
    Inc(fActiveCounter)
  else
    Inc(fInactiveCounter);
end;

end.
