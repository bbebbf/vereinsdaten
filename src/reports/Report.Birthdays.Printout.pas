unit Report.Birthdays.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  Exporter.Types, SqlConnection, Exporter.Birthdays.Types, Report.Base.Printout;

type
  TfmReportBirthdaysPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterBirthdaysParams>)
    bdColumnHeader: TRLBand;
    lbName: TLabel;
    lbAddress: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rtAddress: TRLDBText;
    lbBirthday: TLabel;
    rdColumnHeaderHLine: TRLDraw;
    lbAge: TLabel;
    rdBirthdayWeekday: TRLDBText;
    rdAge: TRLDBText;
    lbFromCaption: TLabel;
    lbToCaption: TLabel;
    lbFromDate: TLabel;
    lbToDate: TLabel;
    rdBirthday: TRLDBText;
    lbOnBirthdaylist: TLabel;
    rdOnBirthdaylist: TRLDBText;
    procedure rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdOnBirthdaylistBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    procedure SetParams(const aParams: TExporterBirthdaysParams);
  strict protected
    function GetReportTitle: string; override;
  end;

implementation

uses Vdm.Globals;

{$R *.dfm}

{ TfmReportBirthdays }

function TfmReportBirthdaysPrintout.GetReportTitle: string;
begin
  Result := 'Geburtstagsliste';
end;

procedure TfmReportBirthdaysPrintout.rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := TVdmGlobals.GetDateAsString(rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdaysPrintout.rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dddd', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdaysPrintout.rdOnBirthdaylistBeforePrint(Sender: TObject; var AText: string;
  var PrintIt: Boolean);
begin
  if rdOnBirthdaylist.Field.AsBoolean then
  begin
    AText := 'X';
  end
  else
  begin
    PrintIt := False;
  end;
end;

procedure TfmReportBirthdaysPrintout.SetParams(const aParams: TExporterBirthdaysParams);
begin
  lbFromDate.Caption := TVdmGlobals.GetDateAsString(aParams.FromDate);
  lbToDate.Caption := TVdmGlobals.GetDateAsString(aParams.ToDate);
  lbOnBirthdaylist.Visible := not aParams.ConsiderBirthdaylistFlag;
  rdOnBirthdaylist.Visible := not aParams.ConsiderBirthdaylistFlag;
end;

end.
