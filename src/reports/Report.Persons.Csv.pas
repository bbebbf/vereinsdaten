unit Report.Persons.Csv;

interface

uses Report.Base.Csv, Exporter.Persons.Types, Exporter.Types;

type
  TReportPersonsCsv = class(TReportBaseCsv, IExporterTarget<TExporterPersonsParams>)
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportPersonsCsv }

function TReportPersonsCsv.GetSuggestedFileName: string;
begin
  Result := 'Personen.csv';
end;

procedure TReportPersonsCsv.SetParams(const aParams: TExporterPersonsParams);
begin

end;

end.
