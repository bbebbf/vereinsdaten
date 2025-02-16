unit MainUI;

interface

uses MainBusinessIntf, ConfigReader, ProgressIndicatorIntf, PersonAggregatedUI, CrudUI,
  DtoUnit, DtoUnitAggregated, MemberOfUI, Vdm.Types;

type
  IMainUI = interface
    ['{27D6AF7C-95A9-442B-BF23-9EF5D1D52EEB}']
    procedure SetBusiness(const aMainBusiness: IMainBusiness);
    procedure SetApplicationTitle(const aTitle: string);
    procedure SetConfiguration(const aConfig: TConfigConnection);

    function GetProgressIndicator: IProgressIndicator;
    function GetPersonAggregatedUI: IPersonAggregatedUI;
    function GetUnitCrudUI: ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>;
    function GetUnitMemberOfsUI: IMemberOfUI;
  end;

implementation

end.
