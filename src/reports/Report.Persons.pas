unit Report.Persons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportPersons = class(TForm)
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
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    Label1: TLabel;
    RLDBText1: TRLDBText;
    rdColumnHeaderHLine: TRLDraw;
    Label2: TLabel;
    RLDBText4: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
  private
    fConnection: ISqlConnection;
    fQuery: ISqlPreparedQuery;
  public
    constructor Create(const aConnection: ISqlConnection); reintroduce;
    procedure Preview;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportPersons }

constructor TfmReportPersons.Create(const aConnection: ISqlConnection);
begin
  inherited Create(nil);
  fConnection := aConnection;
end;

procedure TfmReportPersons.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportPersons.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  fQuery := fConnection.CreatePreparedQuery(
    'SELECT p.person_id, p.person_active, p.person_birthday, pn.person_name, a.address_title' +
    ',IF(p.person_active, null, "X") AS person_inactive' +
    ' FROM person AS p' +
    ' INNER JOIN `vw_person_name` AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN `person_address` AS pa ON pa.person_id = p.person_id' +
    ' LEFT JOIN `vw_select_address` AS a ON a.adr_id = pa.adr_id' +
    ' ORDER BY pn.person_name'
  );
  fQuery.ConfigureDatasource(dsDataSource);
  fQuery.Open;
end;

end.
