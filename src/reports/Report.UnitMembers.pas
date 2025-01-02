unit Report.UnitMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportUnitMembers = class(TForm)
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
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    rdUinitId: TRLDBText;
    rdUnitDivider: TRLDraw;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
    fPreviousUnitId: UInt32;
    fNewPageStarted: Boolean;
  public
    constructor Create(const aConnection: ISqlConnection); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader;

{$R *.dfm}

{ TfmReportUnitMembers }

constructor TfmReportUnitMembers.Create(const aConnection: ISqlConnection);
begin
  inherited Create(nil);
  fConnection := aConnection;
end;

procedure TfmReportUnitMembers.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousUnitId := rdUinitId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitMembers.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportUnitMembers.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdUinitId.Field.AsLargeInt <> fPreviousUnitId);
end;

procedure TfmReportUnitMembers.rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  PrintIt := fNewPageStarted or (rdUinitId.Field.AsLargeInt <> fPreviousUnitId);
end;

procedure TfmReportUnitMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousUnitId := 0;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' LEFT JOIN `member` AS m ON m.unit_id = u.unit_id' +
    ' LEFT JOIN `person` AS p ON p.person_id = m.person_id' +
    ' LEFT JOIN `vw_person_name` AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN `role` AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1' +
    ' AND p.person_active = 1' +
    ' ORDER BY u.unit_name, IFNULL(r.role_sorting, 100000), pn.person_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
end;

procedure TfmReportUnitMembers.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

end.
