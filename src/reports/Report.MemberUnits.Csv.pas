unit Report.MemberUnits.Csv;

interface

uses System.Generics.Collections, Report.Base.Csv, Exporter.Members.Types;

type
  TReportMemberUnitsCsv = class(TReportBaseCsv<TExporterMembersParams>)
  strict protected
    function GetSuggestedFileName: string; override;
    procedure FillFieldsToExport(const aExportParams: TExporterMembersParams;
      const aFields: TObjectList<TReportCsvField>); override;
  end;

implementation

{ TReportMemberUnitsCsv }

procedure TReportMemberUnitsCsv.FillFieldsToExport(const aExportParams: TExporterMembersParams;
  const aFields: TObjectList<TReportCsvField>);
begin
  inherited;
  aFields.Add(TReportCsvField.Create('person_id'));
  aFields.Add(TReportCsvField.Create('person_firstname'));
  aFields.Add(TReportCsvField.Create('person_nameaddition'));
  aFields.Add(TReportCsvField.Create('person_lastname'));
  aFields.Add(TReportCsvField.Create('person_active'));
  aFields.Add(TReportCsvField.Create('person_external'));
  aFields.Add(TReportCsvField.Create('unit_id'));
  aFields.Add(TReportCsvField.Create('unit_name'));
  aFields.Add(TReportCsvField.Create('unit_active'));
  aFields.Add(TReportCsvField.Create('unit_active_since'));
  aFields.Add(TReportCsvField.Create('unit_active_until'));
  aFields.Add(TReportCsvField.Create('mb_active'));
  aFields.Add(TReportCsvField.Create('mb_active_since'));
  aFields.Add(TReportCsvField.Create('mb_active_until'));
  aFields.Add(TReportCsvField.Create('role_name'));
end;

function TReportMemberUnitsCsv.GetSuggestedFileName: string;
begin
  Result := 'Personen_und_Einheiten';
end;

end.
