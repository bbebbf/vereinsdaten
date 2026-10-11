unit Report.Base.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Data.DB, RLReport, SqlConnection, Exporter.Types;

type
  TfmReportBasePrintout = class(TForm)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    lbTenantTitle: TLabel;
    memFilterInfo: TRLMemo;
    bdPageFooter: TRLBand;
    lbAppTitle: TLabel;
    lbSysDate: TRLSystemInfo;
    lbPageNumber: TRLSystemInfo;
    lbLastPageNumber: TRLSystemInfo;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict protected
    function GetReportTitle: string; virtual;
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    function ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
    procedure ExportInternal(const aDataSet: ISqlDataSet); virtual;
    /// <summary>Wird am Ende der gemeinsamen BeforePrint-Behandlung aufgerufen (Zaehler zuruecksetzen o.ae.).</summary>
    procedure DoBeforePrint; virtual;
    /// <summary>Positioniert Mandantentitel, App-Titel und Seitenzahl passend zur Bandbreite.</summary>
    procedure ApplyBandWidth(aBandWidth: Integer);
    procedure SetFilterInfo(const aText: string);
    class function GetPersonInclusionInfo(aIncludeInactive, aIncludeExternal: Boolean): string; static;
  public
    constructor Create; reintroduce;
  end;

implementation

uses
  TenantReader, Vdm.Globals;

{$R *.dfm}

{ TfmReportBasePrintout }

constructor TfmReportBasePrintout.Create;
begin
  inherited Create(nil);
end;

procedure TfmReportBasePrintout.ApplyBandWidth(aBandWidth: Integer);
begin
  lbTenantTitle.Left := aBandWidth - lbTenantTitle.Width;
  lbLastPageNumber.Left := aBandWidth - lbLastPageNumber.Width;
  lbPageNumber.Left := lbLastPageNumber.Left - lbPageNumber.Width;
  lbAppTitle.Left := (aBandWidth - lbAppTitle.Width) div 2;
end;

procedure TfmReportBasePrintout.DoBeforePrint;
begin

end;

function TfmReportBasePrintout.ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
begin
  Result := default(TExporterExportResult);
  Result.Sucessful := True;
  ExportInternal(aDataSet);
end;

procedure TfmReportBasePrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin
  dsDataSource.DataSet := aDataSet.DataSet;
  RLReport.Preview;
end;

function TfmReportBasePrintout.GetReportTitle: string;
begin
  Result := 'Ausdruck';
end;

function TfmReportBasePrintout.GetResultMessageRequired: Boolean;
begin
  Result := False;
end;

function TfmReportBasePrintout.GetTitle: string;
begin
  Result := GetReportTitle;
end;

procedure TfmReportBasePrintout.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lReportTitle := GetReportTitle;
  lbReportTitle.Caption := lReportTitle;
  RLReport.JobTitle := lReportTitle;
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  DoBeforePrint;
end;

class function TfmReportBasePrintout.GetPersonInclusionInfo(aIncludeInactive, aIncludeExternal: Boolean): string;
begin
  if aIncludeInactive and aIncludeExternal then
    Result := 'Externe und inaktive Personen enthalten.'
  else if aIncludeInactive then
    Result := 'Inaktive Personen enthalten.'
  else if aIncludeExternal then
    Result := 'Externe Personen enthalten.'
  else
    Result := '';
end;

procedure TfmReportBasePrintout.SetFilterInfo(const aText: string);
begin
  memFilterInfo.Lines.Text := aText;
  memFilterInfo.Visible := Length(aText) > 0;
end;

end.
