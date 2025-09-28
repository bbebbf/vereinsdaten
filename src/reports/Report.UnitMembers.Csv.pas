unit Report.UnitMembers.Csv;

interface

uses Report.Base.Csv, Exporter.UnitMembers.Types, Exporter.Types;

type
  TReportUnitMembersCsv = class(TReportBaseCsv, IExporterTarget<TExporterUnitMembersParams>)
  strict private
    procedure SetParams(const aParams: TExporterUnitMembersParams);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportUnitMembersCsv }

function TReportUnitMembersCsv.GetSuggestedFileName: string;
begin
  Result := 'Einheiten_und_Personen.csv';
end;

procedure TReportUnitMembersCsv.SetParams(const aParams: TExporterUnitMembersParams);
begin

end;

end.
