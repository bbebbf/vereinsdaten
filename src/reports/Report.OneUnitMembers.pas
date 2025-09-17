unit Report.OneUnitMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Report.Base, Exporter.TargetIntf, Exporter.OneUnitMembers;

type
  TfmReportOneUnitMembers = class(TfmReportBase, IExporterTarget<TExporterOneUnitMembersParams>)
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
  strict private
    fNewPageStarted: Boolean;
    procedure SetParams(const aParams: TExporterOneUnitMembersParams);
    procedure DoExport(const aDataSet: ISqlDataSet);
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportOneUnitMembers }

procedure TfmReportOneUnitMembers.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportOneUnitMembers.bdDetailAfterPrint(Sender: TObject);
begin
  fNewPageStarted := False;
end;

procedure TfmReportOneUnitMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
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

procedure TfmReportOneUnitMembers.SetParams(const aParams: TExporterOneUnitMembersParams);
begin

end;

end.
