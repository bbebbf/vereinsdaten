unit MainBusinessIntf;

interface

uses System.SysUtils, Vdm.Types, CrudUI, DtoAddress, DtoAddressAggregated, DtoRole, DtoTenant;

type
  IMainBusiness = interface
    ['{0ED9F453-D488-46D0-BA5E-94FD610D2E5A}']
    procedure Initialize;
    procedure UIIsReady;
    procedure OpenCrudAddress(const aAdressUI: ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>;
      const aModalProc: TFunc<Integer>);
    procedure OpenCrudRole(const aRoleUI: ICrudUI<TDtoRole, TDtoRole, UInt32, TVoid>;
      const aModalProc: TFunc<Integer>);
    procedure OpenCrudTenant(const aTenantUI: ICrudUI<TDtoTenant, TDtoTenant, UInt8, TVoid>;
      const aModalProc: TFunc<Integer>);

    procedure OpenReportClubMembers;
    procedure OpenReportMemberUnits;
    procedure OpenReportPersons;
    procedure OpenReportUnitMembers;
    procedure OpenReportUnitRoles;

    procedure SwitchedFromPersonsToUnitsCrud;
    procedure SwitchedFromUnitsToPersonsCrud;
  end;

implementation

end.
