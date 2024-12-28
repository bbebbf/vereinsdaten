unit Vdm.Versioning.Types;

interface

type
  TEntryVersionInfoEntity = (Undefined, PersonBaseData, PersonMemberOfs, Units);

  TEntryVersionInfo = record
    Id: UInt32;
    VersionNumber: UInt32;
    LastUpdated: TDateTime;
  end;

implementation

end.
