unit Report.Birthdays.Csv;

interface

uses Report.Base.Csv, Exporter.Birthdays.Types, Exporter.Types;

type
  TReportBirthdaysCsv = class(TReportBaseCsv, IExporterTarget<TExporterBirthdaysParams>)
  strict private
    procedure SetParams(const aParams: TExporterBirthdaysParams);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportBirthdaysCsv }

function TReportBirthdaysCsv.GetSuggestedFileName: string;
begin
  Result := 'Geburtstage.csv';
end;

procedure TReportBirthdaysCsv.SetParams(const aParams: TExporterBirthdaysParams);
begin

end;

end.
