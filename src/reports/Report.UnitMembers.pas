unit Report.UnitMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  SqlConnection, Exporter.TargetIntf;

type
  TfmReportUnitMembers = class(TForm, IExporterTarget<TObject>)
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
    lbAppTitle: TLabel;
    Label1: TLabel;
    rdUnitDataConfirmed: TRLDBText;
    rdMemberCount: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fPreviousUnitId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    procedure SetParams(const aParams: TObject);
    procedure DoExport(const aDataSet: ISqlDataSet);
  public
    constructor Create; reintroduce;
  end;

implementation

uses TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportUnitMembers }

constructor TfmReportUnitMembers.Create;
begin
  inherited Create(nil);
end;

procedure TfmReportUnitMembers.DoExport(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportUnitMembers.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  if fOneUnitPerPage then
  begin
    if not fNewPageStarted and lUnitBreak then
    begin
      bdDetail.FGreenBarFlag := False;
      bdDetail.PageBreaking := pbBeforePrint
    end
    else
    begin
      bdDetail.PageBreaking := pbNone;
    end;
  end;
end;

procedure TfmReportUnitMembers.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousUnitId := rdUinitId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitMembers.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
end;

procedure TfmReportUnitMembers.rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
  if (Sender = rdUnitname) and (rdMemberCount.Field.AsInteger > 5) then
  begin
    AText := AText + ' (' + IntToStr(rdMemberCount.Field.AsInteger) + ' Pers.)';
  end;
end;

procedure TfmReportUnitMembers.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fPreviousUnitId := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
end;

procedure TfmReportUnitMembers.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportUnitMembers.SetParams(const aParams: TObject);
begin

end;

end.
