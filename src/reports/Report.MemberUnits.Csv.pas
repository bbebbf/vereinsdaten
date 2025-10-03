unit Report.MemberUnits.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Persons.Types, Exporter.Types;

type
  TReportMemberUnitsCsv = class(TReportBaseCsv, IExporterTarget<TExporterPersonsParams>)
  strict private
    procedure SetParams(const aParams: TExporterPersonsParams);
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportMemberUnitsCsv }

procedure TReportMemberUnitsCsv.FillFieldsToExport(const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('unit_id'));
  aFields.Add(TReportCsvField.Create('unit_name'));
  aFields.Add(TReportCsvField.Create('role_name'));
end;

function TReportMemberUnitsCsv.GetSuggestedFileName: string;
begin
  Result := 'Personen_und_Einheiten.csv';
end;

procedure TReportMemberUnitsCsv.SetParams(const aParams: TExporterPersonsParams);
begin

end;

end.
