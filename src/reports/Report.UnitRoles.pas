unit Report.UnitRoles;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Report.Base, Exporter.TargetIntf;

type
  TfmReportUnitRoles = class(TfmReportBase, IExporterTarget<TObject>)
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
  strict private
    fPreviousRoleId: UInt32;
    fNewPageStarted: Boolean;
    procedure SetParams(const aParams: TObject);
    procedure DoExport(const aDataSet: ISqlDataSet);
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportUnitRoles }

procedure TfmReportUnitRoles.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportUnitRoles.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousRoleId := rdRoleId.Field.AsLargeInt;
  fNewPageStarted := False;
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
end;

procedure TfmReportUnitRoles.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportUnitRoles.SetParams(const aParams: TObject);
begin

end;

end.
