unit Report.ClubMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, SqlConnection, Vcl.StdCtrls, Vcl.ExtCtrls,
  Exporter.Types, Report.Base.Printout, Exporter.ClubMembers.Types;

type
  TfmReportClubMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterClubMembersParams>)
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rdNumber: TRLDBText;
    rdBirthday: TRLDBText;
    rdAddress: TRLDBText;
    bdColumnHeader: TRLBand;
    lbNumber: TLabel;
    lbName: TLabel;
    lbBirthday: TLabel;
    lbAddress: TLabel;
    lbStartDate: TLabel;
    rdStartDate: TRLDBText;
    lbInactive: TLabel;
    lbEndDate: TLabel;
    rdEndDate: TRLDBText;
    rdInactive: TRLDBText;
    lbEndReason: TLabel;
    rdEndReason: TRLDBText;
    bdSummary: TRLBand;
    lbActiveInactive: TLabel;
    procedure rdInactiveAfterPrint(Sender: TObject);
    procedure bdSummaryBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fActiveCounter: Integer;
    fInactiveCounter: Integer;
    fPortrait: Boolean;
    procedure ApplyLayout;
    procedure SetParams(const aParams: TExporterClubMembersParams);
  strict protected
    function GetReportTitle: string; override;
    procedure DoBeforePrint; override;
  end;

implementation

uses RLTypes, StringTools;

{$R *.dfm}

{ TfmReportClubMembers }

function TfmReportClubMembersPrintout.GetReportTitle: string;
begin
  Result := 'Vereinsmitglieder';
end;

procedure TfmReportClubMembersPrintout.DoBeforePrint;
begin
  inherited;
  fActiveCounter := 0;
  fInactiveCounter := 0;
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

  ApplyBandWidth(lBandWidth);
end;

procedure TfmReportClubMembersPrintout.SetParams(const aParams: TExporterClubMembersParams);
begin
  var lFilterInfo := '';
  if aParams.IncludeInactive then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Enthält inaktive Vereinsmitglieder.');
  end;
  if aParams.SortedByName then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Nach Name sortiert.');
  end;

  SetFilterInfo(lFilterInfo);

  bdSummary.Visible := aParams.IncludeInactive;

  lbInactive.Visible := aParams.IncludeInactive;
  lbEndDate.Visible := aParams.IncludeInactive;
  lbEndReason.Visible := aParams.IncludeInactive;
  rdInactive.Visible := aParams.IncludeInactive;
  rdEndDate.Visible := aParams.IncludeInactive;
  rdEndReason.Visible := aParams.IncludeInactive;

  fPortrait := not aParams.IncludeInactive;
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
