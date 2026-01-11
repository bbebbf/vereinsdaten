unit Report.Birthdays.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Birthdays.Types;

type
  TReportBirthdaysCsv = class(TReportBaseCsv<TExporterBirthdaysParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterBirthdaysParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportBirthdaysCsv }

procedure TReportBirthdaysCsv.FillFieldsToExport(const aExportParams: TExporterBirthdaysParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('birthday'));
  aFields.Add(TReportCsvField.Create('age'));
  aFields.Add(TReportCsvField.Create('person_date_of_birth'));
  if not aExportParams.ConsiderBirthdaylistFlag then
    aFields.Add(TReportCsvField.Create('person_on_birthday_list'));
end;

function TReportBirthdaysCsv.GetSuggestedFileName: string;
begin
  Result := 'Geburtstage';
end;

end.
