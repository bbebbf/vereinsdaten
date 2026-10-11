unit Report.ClubMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, SqlConnection, Vcl.StdCtrls, Vcl.ExtCtrls,
  Exporter.Types, Report.Base.Printout, Exporter.ClubMembers.Types;

type
  TfmReportClubMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterClubMembersParams>)
    bdDetail: TRLBand;
    RLDBText1: TRLDBText;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    RLDBText4: TRLDBText;
    bdColumnHeader: TRLBand;
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
  if aParams.OnlyActive then
  begin
    lFilterInfo := 'Nur aktive Vereinsmitglieder.';
  end;
  if aParams.SortedByName then
  begin
    lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, 'Nach Name sortiert.');
  end;

  SetFilterInfo(lFilterInfo);

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
