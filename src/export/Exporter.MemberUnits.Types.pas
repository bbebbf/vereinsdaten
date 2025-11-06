unit Exporter.MemberUnits.Types;

interface

uses Exporter.Persons.Types;

type
  TExporterMemberUnitsParams = class(TExporterPersonsParams)
  public
    IncludeAllInactiveEntries: Boolean;
    InactiveButActiveUntil: TDate;
  end;


implementation

end.
