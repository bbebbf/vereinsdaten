unit Report.UnitRoles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportUnitRoles = class(TForm)
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
    rdRoleName: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    rdRoleId: TRLDBText;
    rdDivider: TRLDraw;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    Label1: TLabel;
    RLDBText1: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdRoleNameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
    fPreviousRoleId: UInt32;
    fNewPageStarted: Boolean;
  public
    constructor Create(const aConnection: ISqlConnection); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportUnitRoles }

constructor TfmReportUnitRoles.Create(const aConnection: ISqlConnection);
begin
  inherited Create(nil);
  fConnection := aConnection;
end;

procedure TfmReportUnitRoles.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousRoleId := rdRoleId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitRoles.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportUnitRoles.rdDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdRoleId.Field.AsLargeInt <> fPreviousRoleId);
end;

procedure TfmReportUnitRoles.rdRoleNameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdRoleId.Field.AsLargeInt <> fPreviousRoleId);
end;

procedure TfmReportUnitRoles.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousRoleId := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT r.role_id, r.role_name, u.unit_name, u.unit_data_confirmed_on, pn.person_name' +
    ' FROM role AS r' +
    ' INNER JOIN member AS m ON m.role_id = r.role_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' INNER JOIN unit AS u ON u.unit_id = m.unit_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1' +
    ' AND p.person_active = 1' +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', r.role_name, u.unit_name, pn.person_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
end;

procedure TfmReportUnitRoles.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

end.
