unit Vdm.Types;

interface

type
  TVoid = record end;

  TEntryVersionInfo = record
    Id: UInt32;
    Versionnumber: UInt32;
    LastUpdate: TDateTime;
  end;

  TUnitFilter = record
    ShowInactiveUnits: Boolean;
  end;

implementation

end.
