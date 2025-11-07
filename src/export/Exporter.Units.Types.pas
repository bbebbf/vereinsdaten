unit Exporter.Units.Types;

interface

type
  TExporterUnitsParams = class
  public
    IncludeAllInactive: Boolean;
    InactiveButActiveUntil: TDate;
    SelectedUnitId: UInt32;
    CheckedUnitIds: TArray<UInt32>;
    ExportOneUnitDetails: UInt32;
  end;


implementation

end.
