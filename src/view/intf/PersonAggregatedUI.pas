unit PersonAggregatedUI;

interface

uses CrudUI, DtoPersonAggregated, MainBusinessIntf, PersonMemberOfUI;

type
  IPersonAggregatedUI = interface(ICrudUI<TDtoPersonAggregated, UInt32>)
    ['{552E9650-B9A1-49F1-91CC-3520E5847F79}']
    procedure Initialize(const aCommands: IMainBusinessIntf);
    procedure LoadAvailableAdresses;
    procedure LoadCurrentEntry(const aPersonId: UInt32);
    function GetMemberOfUI: IPersonMemberOfUI;
  end;

implementation

end.
