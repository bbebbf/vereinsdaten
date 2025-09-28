unit Report.MemberUnits.Csv;

interface

uses Report.Base.Csv, Exporter.Persons.Types, Exporter.Types;

type
  TReportMemberUnitsCsv = class(TReportBaseCsv, IExporterTarget<TExporterPersonsParams>)
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportMemberUnitsCsv }

function TReportMemberUnitsCsv.GetSuggestedFileName: string;
begin
  Result := 'Einheiten_und_Personen.csv';
end;

procedure TReportMemberUnitsCsv.SetParams(const aParams: TExporterPersonsParams);
begin

end;

end.
