unit Report.ClubMembers.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Types;

type
  TReportClubMembersCsv = class(TReportBaseCsv, IExporterTarget<TObject>)
  strict private
    procedure SetParams(const aParams: TObject);
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportClubMembersCsv }

procedure TReportClubMembersCsv.FillFieldsToExport(const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('clmb_number'));
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('person_date_of_birth'));
  aFields.Add(TReportCsvField.Create('address_street'));
  aFields.Add(TReportCsvField.Create('address_postalcode'));
  aFields.Add(TReportCsvField.Create('address_city'));
  aFields.Add(TReportCsvField.Create('clmb_startdate'));
  aFields.Add(TReportCsvField.Create('clmb_active'));
  aFields.Add(TReportCsvField.Create('clmb_enddate_calculated'));
  aFields.Add(TReportCsvField.Create('clmb_endreason'));
end;

function TReportClubMembersCsv.GetSuggestedFileName: string;
begin
  Result := 'Vereinsmitglieder.csv';
end;

procedure TReportClubMembersCsv.SetParams(const aParams: TObject);
begin

end;

end.
