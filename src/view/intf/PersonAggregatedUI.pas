unit PersonAggregatedUI;

interface

uses CrudUI, DtoPersonAggregated, MainBusinessIntf;

type
  IPersonAggregatedUI = interface(ICrudUI<TDtoPersonAggregated, Int32>)
    ['{552E9650-B9A1-49F1-91CC-3520E5847F79}']
    procedure Initialize(const aCommands: IMainBusinessIntf);
    procedure LoadAvailableAdresses;
    procedure LoadCurrentRecord(const aPersonId: Int32);
  end;

implementation

end.
