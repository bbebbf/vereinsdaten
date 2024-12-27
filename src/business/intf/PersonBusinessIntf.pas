unit PersonBusinessIntf;

interface

uses CrudCommands, KeyIndexStrings;

type
  IPersonBusinessIntf = interface(ICrudCommands<UInt32>)
    ['{47719CB5-C17A-4DF3-A0CC-E2D0567F0F88}']
    function GetAvailableAddresses: TKeyIndexStrings;
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);
    procedure LoadPersonsMemberOfs;
    procedure ClearAddressCache;
    procedure ClearUnitCache;
    procedure ClearRoleCache;
    property ShowInactivePersons: Boolean read GetShowInactivePersons write SetShowInactivePersons;
    property AvailableAddresses: TKeyIndexStrings read GetAvailableAddresses;
  end;

implementation

end.
