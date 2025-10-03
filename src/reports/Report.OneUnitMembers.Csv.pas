unit Report.OneUnitMembers.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.OneUnitMembers;

type
  TReportOneUnitMembersCsv = class(TReportBaseCsv<TExporterOneUnitMembersParams>)
  strict protected
    procedure FillFieldsToExport(const aExportParams: TExporterOneUnitMembersParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportOneUnitMembersCsv }

{ TReportOneUnitMembersCsv }

procedure TReportOneUnitMembersCsv.FillFieldsToExport(const aExportParams: TExporterOneUnitMembersParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('unit_id'));
  aFields.Add(TReportCsvField.Create('unit_name'));
  aFields.Add(TReportCsvField.Create('unit_data_confirmed_on'));
  aFields.Add(TReportCsvField.Create('unit_member_count'));
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('address_street'));
  aFields.Add(TReportCsvField.Create('address_postalcode'));
  aFields.Add(TReportCsvField.Create('address_city'));
  aFields.Add(TReportCsvField.Create('role_name'));
end;

end.
