unit Report.OneUnitMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.OneUnitMembers, Report.Base.Printout;

type
  TfmReportOneUnitMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterOneUnitMembersParams>)
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
    lbAddress: TLabel;
    rtAddress: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure RLReportPageStarting(Sender: TObject);
    procedure rdMemberCountBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    fNewPageStarted: Boolean;
    procedure SetParams(const aParams: TExporterOneUnitMembersParams);
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportOneUnitMembers }

procedure TfmReportOneUnitMembersPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportOneUnitMembersPrintout.rdMemberCountBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  if rdMemberCount.Field.IsNull then
    AText := '0';
end;

procedure TfmReportOneUnitMembersPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fNewPageStarted := False;
end;

procedure TfmReportOneUnitMembersPrintout.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
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

procedure TfmReportOneUnitMembersPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportOneUnitMembersPrintout.SetParams(const aParams: TExporterOneUnitMembersParams);
begin

end;

end.
