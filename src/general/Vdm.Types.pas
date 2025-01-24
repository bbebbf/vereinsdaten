unit Vdm.Types;

interface

uses DelayedExecute;

type
  TVoid = record end;

  TUnitFilter = record
    ShowInactiveUnits: Boolean;
  end;

  TDelayedLoadEntryData = record
    RecordId: UInt32;
    RecordFound: Boolean;
    StartEdit: Boolean;
    constructor Create(const aRecordId: UInt32; const aRecordFound, aStartEdit: Boolean);
  end;

  TDelayedLoadEntry = TDelayedExecute<TDelayedLoadEntryData>;

  TMemberOfMaster = (MasterPerson, MasterUnit);

implementation

{ TDelayedLoadEntryData }

constructor TDelayedLoadEntryData.Create(const aRecordId: UInt32; const aRecordFound, aStartEdit: Boolean);
begin
  Self := default(TDelayedLoadEntryData);
  Self.RecordId := aRecordId;
  Self.RecordFound := aRecordFound;
  Self.StartEdit := aStartEdit;
end;

end.
