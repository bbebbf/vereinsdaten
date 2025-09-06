unit Report.Persons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.TargetIntf, Exporter.Persons;

type
  TfmReportPersons = class(TForm, IExporterTarget<TExporterPersonsParams>)
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
    Label2: TLabel;
    RLDBText4: TRLDBText;
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
    procedure DoExport(const aDataSet: ISqlDataSet);
  public
    constructor Create; reintroduce;
  end;

implementation

uses TenantReader, Vdm.Globals, VclUITools;

{$R *.dfm}

{ TfmReportPersons }

constructor TfmReportPersons.Create;
begin
  inherited Create(nil);
end;

procedure TfmReportPersons.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportPersons.SetParams(const aParams: TExporterPersonsParams);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;

  if not aParams.ShowInactivePersons then
  begin
    TVclUITools.HideAndMoveHorizontal(lbInactive, [lbBirthday, lbAddress, rtBirthday, rtAddress]);
    rtInactive.Visible := False;
  end;
end;

end.
