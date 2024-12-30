unit VersionInfoEntryUI;

interface

uses Vdm.Versioning.Types;

type
  IVersionInfoEntryUI = interface
    ['{05190B9B-EB67-411D-9ACB-25CF7C7BC722}']
    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16 = 0);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16 = 0);
  end;

implementation

end.
