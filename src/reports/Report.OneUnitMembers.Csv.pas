unit Report.OneUnitMembers.Csv;

interface

uses Report.Base.Csv, Exporter.OneUnitMembers, Exporter.Types;

type
  TReportOneUnitMembersCsv = class(TReportBaseCsv, IExporterTarget<TExporterOneUnitMembersParams>)
  strict private
    procedure SetParams(const aParams: TExporterOneUnitMembersParams);
  end;

implementation

{ TReportOneUnitMembersCsv }

procedure TReportOneUnitMembersCsv.SetParams(const aParams: TExporterOneUnitMembersParams);
begin

end;

end.
