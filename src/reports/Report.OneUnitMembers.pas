unit Report.OneUnitMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportOneUnitMembers = class(TForm)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbTenantTitle: TLabel;
    bdColumnHeader: TRLBand;
    Label4: TLabel;
    Label5: TLabel;
    bdDetail: TRLBand;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    rdUnitname: TRLDBText;
    rdUnitDataConfirmed: TRLDBText;
    Label1: TLabel;
    rdMemberCount: TRLDBText;
    Label2: TLabel;
    rdUnitDivider: TRLDraw;
    lbBirthday: TLabel;
    lbAddress: TLabel;
    rtBirthday: TRLDBText;
    rtAddress: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure RLReportPageStarting(Sender: TObject);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
    fUnitId: UInt32;
    fNewPageStarted: Boolean;
  public
    constructor Create(const aConnection: ISqlConnection; const aUnitId: UInt32); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportOneUnitMembers }

constructor TfmReportOneUnitMembers.Create(const aConnection: ISqlConnection; const aUnitId: UInt32);
begin
  inherited Create(nil);
  fConnection := aConnection;
  fUnitId := aUnitId;
end;

procedure TfmReportOneUnitMembers.bdDetailAfterPrint(Sender: TObject);
begin
  fNewPageStarted := False;
end;

procedure TfmReportOneUnitMembers.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportOneUnitMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, mc.MemberCount, pn.person_name, p.person_birthday, a.address_title, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN (' +
          ' SELECT m.unit_id, COUNT(*) AS MemberCount' +
          ' FROM member AS m' +
          ' INNER JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
          ' WHERE  m.mb_active = 1' +
          ' GROUP BY m.unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id' +
    ' LEFT JOIN member AS m ON m.unit_id = u.unit_id AND m.mb_active = 1' +
    ' LEFT JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' LEFT JOIN vw_select_address AS a ON a.adr_id = pa.adr_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_id = ' + UIntToStr(fUnitId) +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
  if dsDataSource.DataSet.Eof then
  begin
    RLReport.JobTitle := 'Unbekannte Einheit';
  end
  else
  begin
    RLReport.JobTitle := dsDataSource.DataSet.FieldByName('unit_name').AsString;
  end;
end;

procedure TfmReportOneUnitMembers.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

end.
