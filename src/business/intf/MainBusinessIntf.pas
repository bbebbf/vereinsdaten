unit MainBusinessIntf;

interface

uses System.Classes, CrudCommands;

type
  IMainBusinessIntf = interface(ICrudCommands<UInt32>)
    ['{47719CB5-C17A-4DF3-A0CC-E2D0567F0F88}']
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);
    procedure LoadAvailableAddresses(const aStrings: TStrings);
    property ShowInactivePersons: Boolean read GetShowInactivePersons write SetShowInactivePersons;
  end;

implementation

end.
