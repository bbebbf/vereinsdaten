unit PersonAggregatedUI;

interface

uses CrudUI, DtoPerson, DtoPersonAggregated, MainBusinessIntf, PersonMemberOfUI;

type
  IPersonAggregatedUI = interface(ICrudUI<TDtoPersonAggregated, TDtoPerson, UInt32>)
    ['{552E9650-B9A1-49F1-91CC-3520E5847F79}']
    procedure SetMainBusinessIntf(const aCommands: IMainBusinessIntf);
    procedure UnsetMainBusinessIntf;
    procedure LoadAvailableAdresses;
    procedure LoadCurrentEntry(const aPersonId: UInt32);
    function GetMemberOfUI: IPersonMemberOfUI;
  end;

implementation

end.
