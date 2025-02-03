unit PersonAggregatedUI;

interface

uses CrudUI, DtoPerson, DtoPersonAggregated, PersonBusinessIntf, MemberOfUI, Vdm.Types;

type
  IPersonAggregatedUI = interface(ICrudUI<TDtoPersonAggregated, TDtoPerson, UInt32, TVoid>)
    ['{552E9650-B9A1-49F1-91CC-3520E5847F79}']
    procedure SetPersonBusinessIntf(const aCommands: IPersonBusinessIntf);
    procedure LoadCurrentEntry(const aPersonId: UInt32);
    function GetMemberOfUI: IMemberOfUI;
  end;

implementation

end.
