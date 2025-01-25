unit Report.MemberUnits;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportMemberUnits = class(TForm)
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
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
    fPreviousPersonId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
  public
    constructor Create(const aConnection: ISqlConnection); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportMemberUnits }

constructor TfmReportMemberUnits.Create(const aConnection: ISqlConnection);
begin
  inherited Create(nil);
  fConnection := aConnection;
end;

procedure TfmReportMemberUnits.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
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

procedure TfmReportMemberUnits.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousPersonId := rdPersonid.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportMemberUnits.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportMemberUnits.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId);
end;

procedure TfmReportMemberUnits.rdPersonnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdPersonid.Field.AsLargeInt <> fPreviousPersonId);
end;

procedure TfmReportMemberUnits.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousPersonId := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_id, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN `member` AS m ON m.unit_id = u.unit_id' +
    ' INNER JOIN `person` AS p ON p.person_id = m.person_id' +
    ' INNER JOIN `vw_person_name` AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN `role` AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1' +
    ' AND p.person_active = 1' +
    ' ORDER BY pn.person_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
end;

procedure TfmReportMemberUnits.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

end.
