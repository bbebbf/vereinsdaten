unit Report.ClubMembers.Csv;

interface

uses Report.Base.Csv, Exporter.Types;

type
  TReportClubMembersCsv = class(TReportBaseCsv, IExporterTarget<TObject>)
  strict private
    procedure SetParams(const aParams: TObject);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportClubMembersCsv }

function TReportClubMembersCsv.GetSuggestedFileName: string;
begin
  Result := 'Vereinsmitlieder.csv';
end;

procedure TReportClubMembersCsv.SetParams(const aParams: TObject);
begin

end;

end.
