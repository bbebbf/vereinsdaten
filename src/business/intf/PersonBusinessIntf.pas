unit PersonBusinessIntf;

interface

uses CrudCommands, KeyIndexStrings, Vdm.Types;

type
  IPersonBusinessIntf = interface(ICrudCommands<UInt32, TVoid>)
    ['{47719CB5-C17A-4DF3-A0CC-E2D0567F0F88}']
    function GetAvailableAddresses: TActiveKeyIndexStringsLoader;
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);
    function LoadPerson(const aPersonId: UInt32; const aLoadMemberOfs: Boolean): TCrudCommandResult;
    procedure LoadPersonsMemberOfs;
    procedure ClearAddressCache;
    property ShowInactivePersons: Boolean read GetShowInactivePersons write SetShowInactivePersons;
    property AvailableAddresses: TActiveKeyIndexStringsLoader read GetAvailableAddresses;
  end;

implementation

end.
