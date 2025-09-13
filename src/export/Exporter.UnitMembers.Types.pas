unit Exporter.UnitMembers.Types;

interface

type
  TExporterUnitMembersParams = class
  public
    SelectedUnitId: UInt32;
    CheckedUnitIds: TArray<UInt32>;
    ExportOneUnitDetails: UInt32;
  end;

implementation

end.
