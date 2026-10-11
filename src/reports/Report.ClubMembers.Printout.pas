unit Report.ClubMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, SqlConnection, Vcl.StdCtrls, Vcl.ExtCtrls,
  Exporter.Types, Report.Base.Printout, Exporter.ClubMembers.Types;

type
  TfmReportClubMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterClubMembersParams>)
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
    memFilterInfo: TRLMemo;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdInactiveAfterPrint(Sender: TObject);
    procedure bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fActiveCounter: Integer;
    fInactiveCounter: Integer;
    fPortrait: Boolean;
    procedure ApplyLayout;
    procedure SetParams(const aParams: TExporterClubMembersParams);
  strict protected
    procedure ExportInternal(const aDataSet: ISqlDataSet); override;
  end;

implementation

uses RLTypes, TenantReader, Vdm.Globals, StringTools;

{$R *.dfm}

{ TfmReportClubMembers }

procedure TfmReportClubMembersPrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

procedure TfmReportClubMembersPrintout.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  fActiveCounter := 0;
  fInactiveCounter := 0;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  ApplyLayout;
end;

procedure TfmReportClubMembersPrintout.ApplyLayout;
const
  cLandscapeBandWidth = 1355;
  cPortraitBandWidth = 944;
begin
  var lBandWidth := cLandscapeBandWidth;
  if fPortrait then
  begin
    lBandWidth := cPortraitBandWidth;
    RLReport.PageSetup.Orientation := poPortrait;
  end
  else
  begin
    RLReport.PageSetup.Orientation := poLandscape;
  end;

  lbTenantTitle.Left := lBandWidth - lbTenantTitle.Width;
  RLSystemInfo4.Left := lBandWidth - RLSystemInfo4.Width;
  RLSystemInfo3.Left := RLSystemInfo4.Left - RLSystemInfo3.Width;
  lbAppTitle.Left := (lBandWidth - lbAppTitle.Width) div 2;
end;

procedure TfmReportClubMembersPrintout.SetParams(const aParams: TExporterClubMembersParams);
begin
  var lFilterInfo := '';
  if aParams.OnlyActive then
  begin
    lFilterInfo := 'Nur aktive Vereinsmitglieder.';
  end;
  if aParams.SortedByName then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Nach Name sortiert.');
  end;

  memFilterInfo.Lines.Text := lFilterInfo;
  memFilterInfo.Visible := Length(lFilterInfo) > 0;

  bdSummary.Visible := not aParams.OnlyActive;

  Label8.Visible := not aParams.OnlyActive;
  Label9.Visible := not aParams.OnlyActive;
  Label7.Visible := not aParams.OnlyActive;
  rdInactive.Visible := not aParams.OnlyActive;
  RLDBText6.Visible := not aParams.OnlyActive;
  RLDBText8.Visible := not aParams.OnlyActive;

  fPortrait := aParams.OnlyActive;
  ApplyLayout;
end;

procedure TfmReportClubMembersPrintout.bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbActiveInactive.Caption := 'Aktive: ' + IntToStr(fActiveCounter) + ' / Inaktive: ' + IntToStr(fInactiveCounter);
end;

procedure TfmReportClubMembersPrintout.rdInactiveAfterPrint(Sender: TObject);
begin
  if Length(rdInactive.Field.AsString) = 0 then
    Inc(fActiveCounter)
  else
    Inc(fInactiveCounter);
end;

end.
