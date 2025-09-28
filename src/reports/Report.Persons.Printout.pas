unit Report.Persons.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Persons.Types, Report.Base.Printout;

type
  TfmReportPersonsPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterPersonsParams>)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    lbTenantTitle: TLabel;
    bdColumnHeader: TRLBand;
    Label3: TLabel;
    lbInactive: TLabel;
    lbAddress: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rtInactive: TRLDBText;
    rtAddress: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    lbBirthday: TLabel;
    rtBirthday: TRLDBText;
    rdColumnHeaderHLine: TRLDraw;
    lbExternal: TLabel;
    rtExternal: TRLDBText;
    lbSpecialPersonsInfo: TRLLabel;
    procedure rtBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses TenantReader, Vdm.Globals, VclUITools;

{$R *.dfm}

{ TfmReportPersons }

procedure TfmReportPersonsPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportPersonsPrintout.rtBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  var lFieldDayOfBirth := RLReport.DataSource.DataSet.FieldByName('person_day_of_birth');
  var lFieldMonthOfBirth := RLReport.DataSource.DataSet.FieldByName('person_month_of_birth');
  if rtBirthday.Field.IsNull and not lFieldDayOfBirth.IsNull and not lFieldMonthOfBirth.IsNull then
  begin
    AText := FormatDateTime('dd/mm/', EncodeDate(2024, lFieldMonthOfBirth.AsInteger, lFieldDayOfBirth.AsInteger));
  end;
end;

procedure TfmReportPersonsPrintout.SetParams(const aParams: TExporterPersonsParams);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  if not aParams.ShowExternalPersons then
  begin
    TVclUITools.HideAndMoveHorizontal(lbExternal, [lbInactive, lbBirthday, lbAddress, rtInactive, rtBirthday, rtAddress]);
    rtExternal.Visible := False;
  end;
  if not aParams.ShowInactivePersons then
  begin
    TVclUITools.HideAndMoveHorizontal(lbInactive, [lbBirthday, lbAddress, rtBirthday, rtAddress]);
    rtInactive.Visible := False;
  end;

  lbSpecialPersonsInfo.Visible := aParams.ShowInactivePersons or aParams.ShowExternalPersons;
  if aParams.ShowInactivePersons and aParams.ShowExternalPersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Externe und inaktive Personen enthalten.';
  end
  else if aParams.ShowInactivePersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Inaktive Personen enthalten.';
  end
  else if aParams.ShowExternalPersons then
  begin
    lbSpecialPersonsInfo.Caption := 'Externe Personen enthalten.';
  end;
end;

end.
