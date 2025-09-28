unit Report.UnitRoles.Csv;

interface

uses Report.Base.Csv, Exporter.Types;

type
  TReportUnitRolesCsv = class(TReportBaseCsv, IExporterTarget<TObject>)
  strict private
    procedure SetParams(const aParams: TObject);
  strict protected
    function GetSuggestedFileName: string; override;
  end;

implementation

{ TReportUnitRolesCsv }

function TReportUnitRolesCsv.GetSuggestedFileName: string;
begin
  Result := 'Rollen_und_Einheiten.csv';
end;

procedure TReportUnitRolesCsv.SetParams(const aParams: TObject);
begin

end;

end.
