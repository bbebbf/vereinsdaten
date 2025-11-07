unit Report.UnitMembers.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Members.Types;

type
  TReportUnitMembersCsv = class(TReportBaseCsv<TExporterMembersParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterMembersParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportUnitMembersCsv }

procedure TReportUnitMembersCsv.FillFieldsToExport(const aExportParams: TExporterMembersParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('unit_id'));
  aFields.Add(TReportCsvField.Create('unit_name'));
  aFields.Add(TReportCsvField.Create('unit_kind'));
  aFields.Add(TReportCsvField.Create('unit_data_confirmed_on'));
  aFields.Add(TReportCsvField.Create('unit_member_count'));
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('role_name'));
end;

function TReportUnitMembersCsv.GetSuggestedFileName: string;
begin
  Result := 'Einheiten_und_Personen';
end;

end.
