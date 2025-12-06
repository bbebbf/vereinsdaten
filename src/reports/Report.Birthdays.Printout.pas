unit Report.Birthdays.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  Exporter.Types, SqlConnection, Exporter.Birthdays.Types, Report.Base.Printout;

type
  TfmReportBirthdaysPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterBirthdaysParams>)
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
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses System.IOUtils, System.Generics.Collections, System.DateUtils, TenantReader, Vdm.Globals, VclUITools;

{$R *.dfm}

{ TfmReportBirthdays }

procedure TfmReportBirthdaysPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportBirthdaysPrintout.rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := TVdmGlobals.GetDateAsString(rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdaysPrintout.rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dddd', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdaysPrintout.SetParams(const aParams: TExporterBirthdaysParams);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  lbFromDate.Caption := TVdmGlobals.GetDateAsString(aParams.FromDate);
  lbToDate.Caption := TVdmGlobals.GetDateAsString(aParams.ToDate);
end;

end.
