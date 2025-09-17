unit Report.Birthdays;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  Report.Base, Exporter.TargetIntf, SqlConnection, Exporter.Birthdays.Types;

type
  TfmReportBirthdays = class(TfmReportBase, IExporterTarget<TExporterBirthdaysParams>)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    lbTenantTitle: TLabel;
    bdColumnHeader: TRLBand;
    lbName: TLabel;
    lbAddress: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rtAddress: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    lbBirthday: TLabel;
    rdColumnHeaderHLine: TRLDraw;
    lbAge: TLabel;
    rdBirthdayWeekday: TRLDBText;
    RLDBText1: TRLDBText;
    Label2: TLabel;
    Label1: TLabel;
    lbFromDate: TLabel;
    lbToDate: TLabel;
    rdBirthday: TRLDBText;
    procedure rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    procedure SetParams(const aParams: TExporterBirthdaysParams);
    procedure DoExport(const aDataSet: ISqlDataSet);
  end;

implementation

uses System.IOUtils, System.Generics.Collections, System.DateUtils, TenantReader, Vdm.Globals, VclUITools;

{$R *.dfm}

{ TfmReportBirthdays }

procedure TfmReportBirthdays.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportBirthdays.rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dd.mm.yy', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdays.rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dddd', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdays.SetParams(const aParams: TExporterBirthdaysParams);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  lbFromDate.Caption := FormatDatetime('dd.mm.yyyy', aParams.FromDate);
  lbToDate.Caption := FormatDatetime('dd.mm.yyyy', aParams.ToDate);
end;

end.
