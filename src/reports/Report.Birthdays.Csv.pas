unit Report.Birthdays.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Birthdays.Types, Exporter.Types;

type
  TReportBirthdaysCsv = class(TReportBaseCsv, IExporterTarget<TExporterBirthdaysParams>)
  strict private
    procedure SetParams(const aParams: TExporterBirthdaysParams);
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportBirthdaysCsv }

procedure TReportBirthdaysCsv.FillFieldsToExport(const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('birthday'));
  aFields.Add(TReportCsvField.Create('age'));
  aFields.Add(TReportCsvField.Create('person_date_of_birth'));
end;

function TReportBirthdaysCsv.GetSuggestedFileName: string;
begin
  Result := 'Geburtstage.csv';
end;

procedure TReportBirthdaysCsv.SetParams(const aParams: TExporterBirthdaysParams);
begin

end;

end.
