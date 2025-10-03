unit Report.MemberUnits.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Persons.Types;

type
  TReportMemberUnitsCsv = class(TReportBaseCsv<TExporterPersonsParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterPersonsParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportMemberUnitsCsv }

procedure TReportMemberUnitsCsv.FillFieldsToExport(const aExportParams: TExporterPersonsParams;
  const aFields: TObjectList<TReportCsvField>);
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
  Result := 'Personen_und_Einheiten';
end;

end.
