unit VersionInfoEntryConfig;

interface

uses Vdm.Versioning.Types;

type
  IVersionInfoEntryConfig<TEntry> = interface
    ['{A18242DC-5A4F-47FD-8A4E-82C6F77FE8A3}']
    function GetVersionInfoEntry(const aEntry: TEntry; out aVersionInfoEntry: TVersionInfoEntry): Boolean;
    procedure AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TEntry);
  end;

implementation

end.
