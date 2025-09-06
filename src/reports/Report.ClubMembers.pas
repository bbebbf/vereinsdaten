unit Report.ClubMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, SqlConnection, Vcl.StdCtrls, Vcl.ExtCtrls,
  Exporter.TargetIntf;

type
  TfmReportClubMembers = class(TForm, IExporterTarget<TObject>)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdDetail: TRLBand;
    RLDBText1: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    RLDBText4: TRLDBText;
    bdColumnHeader: TRLBand;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RLDBText5: TRLDBText;
    Label8: TLabel;
    Label9: TLabel;
    RLDBText6: TRLDBText;
    rdInactive: TRLDBText;
    Label7: TLabel;
    RLDBText8: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbTenantTitle: TLabel;
    bdSummary: TRLBand;
    lbActiveInactive: TLabel;
    lbAppTitle: TLabel;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdInactiveAfterPrint(Sender: TObject);
    procedure bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fActiveCounter: Integer;
    fInactiveCounter: Integer;
    procedure SetParams(const aParams: TObject);
    procedure DoExport(const aDataSet: ISqlDataSet);
  public
    { Public-Deklarationen }
    constructor Create; reintroduce;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportClubMembers }

constructor TfmReportClubMembers.Create;
begin
  inherited Create(nil);
end;

procedure TfmReportClubMembers.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportClubMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fActiveCounter := 0;
  fInactiveCounter := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
end;

procedure TfmReportClubMembers.SetParams(const aParams: TObject);
begin

end;

procedure TfmReportClubMembers.bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbActiveInactive.Caption := 'Aktive: ' + IntToStr(fActiveCounter) + ' / Inaktive: ' + IntToStr(fInactiveCounter);
end;

procedure TfmReportClubMembers.rdInactiveAfterPrint(Sender: TObject);
begin
  if Length(rdInactive.Field.AsString) = 0 then
    Inc(fActiveCounter)
  else
    Inc(fInactiveCounter);
end;

end.
