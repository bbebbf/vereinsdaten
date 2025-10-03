unit Report.Persons.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Persons.Types;

type
  TReportPersonsCsv = class(TReportBaseCsv<TExporterPersonsParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterPersonsParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportPersonsCsv }

procedure TReportPersonsCsv.FillFieldsToExport(const aExportParams: TExporterPersonsParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('person_date_of_birth'));
  aFields.Add(TReportCsvField.Create('person_day_of_birth'));
  aFields.Add(TReportCsvField.Create('person_month_of_birth'));
  aFields.Add(TReportCsvField.Create('address_street'));
  aFields.Add(TReportCsvField.Create('address_postalcode'));
  aFields.Add(TReportCsvField.Create('address_city'));
  aFields.Add(TReportCsvField.Create('person_active'));
  aFields.Add(TReportCsvField.Create('person_external'));
end;

function TReportPersonsCsv.GetSuggestedFileName: string;
begin
  Result := 'Personen';
end;

end.
