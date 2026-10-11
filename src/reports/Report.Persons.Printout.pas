unit Report.Persons.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.Persons.Types, Report.Base.Printout;

type
  TfmReportPersonsPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterPersonsParams>)
    bdColumnHeader: TRLBand;
    Label3: TLabel;
    lbAddress: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rtAddress: TRLDBText;
    lbBirthday: TLabel;
    rtBirthday: TRLDBText;
    rdColumnHeaderHLine: TRLDraw;
    lbStatus: TLabel;
    rtStatus: TRLDBText;
    procedure rtBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rtStatusBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
  strict protected
    function GetReportTitle: string; override;
  end;

implementation

uses VclUITools, StringTools;

{$R *.dfm}

{ TfmReportPersons }

function TfmReportPersonsPrintout.GetReportTitle: string;
begin
  Result := 'Personen';
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

procedure TfmReportPersonsPrintout.rtStatusBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  PrintIt := rtStatus.Visible;
  if PrintIt then
    AText := TStringTools.Combine(rtStatus.DataSource.DataSet.FieldByName('person_external_e').AsString,
      ' ', rtStatus.DataSource.DataSet.FieldByName('person_inactive_i').AsString);
end;

procedure TfmReportPersonsPrintout.SetParams(const aParams: TExporterPersonsParams);
begin
  if not aParams.IncludeExternal and not aParams.IncludeInactive then
  begin
    TVclUITools.HideAndMoveHorizontal(lbStatus, [lbBirthday, lbAddress, rtBirthday, rtAddress]);
    rtStatus.Visible := False;
  end;

  SetFilterInfo(GetPersonInclusionInfo(aParams.IncludeInactive, aParams.IncludeExternal));
end;

end.
