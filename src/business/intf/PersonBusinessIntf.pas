unit PersonBusinessIntf;

interface

uses CrudCommands, KeyIndexStrings, ListFilterPerson;

type
  IPersonBusinessIntf = interface(ICrudCommands<UInt32, TListFilterPerson>)
    ['{47719CB5-C17A-4DF3-A0CC-E2D0567F0F88}']
    function GetAvailableAddresses: TActiveKeyIndexStringsLoader;
    function LoadPerson(const aPersonId: UInt32; const aLoadMemberOfs: Boolean): TCrudCommandResult;
    procedure LoadPersonsMemberOfs;
    procedure ClearAddressCache;
    property AvailableAddresses: TActiveKeyIndexStringsLoader read GetAvailableAddresses;
  end;

implementation

end.
