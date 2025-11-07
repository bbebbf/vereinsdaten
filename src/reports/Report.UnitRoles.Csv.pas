unit Report.UnitRoles.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Members.Types;

type
  TReportUnitRolesCsv = class(TReportBaseCsv<TExporterMembersParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterMembersParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportUnitRolesCsv }

procedure TReportUnitRolesCsv.FillFieldsToExport(const aExportParams: TExporterMembersParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('role_name'));
  aFields.Add(TReportCsvField.Create('unit_id'));
  aFields.Add(TReportCsvField.Create('unit_name'));
  aFields.Add(TReportCsvField.Create('unit_data_confirmed_on'));
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
end;

function TReportUnitRolesCsv.GetSuggestedFileName: string;
begin
  Result := 'Rollen_und_Einheiten';
end;

end.
