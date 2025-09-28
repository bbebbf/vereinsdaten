unit MainBusinessIntf;

interface

uses System.SysUtils, Vdm.Types, CrudUI, DtoAddress, DtoAddressAggregated, DtoRole, DtoTenant,
  ParamsProvider, Exporter.Persons.Types, Exporter.UnitMembers.Types, Exporter.Birthdays.Types;

type
  IMainBusiness = interface
    ['{0ED9F453-D488-46D0-BA5E-94FD610D2E5A}']
    procedure Initialize;
    procedure UIIsReady;

    procedure OpenCrudPerson(const aPersonId: UInt32 = 0);
    procedure OpenCrudUnit(const aUnitId: UInt32 = 0);
    procedure OpenCrudAddress(const aAdressUI: ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TEntryFilter>;
      const aModalProc: TFunc<Integer>);
    procedure OpenCrudRole(const aRoleUI: ICrudUI<TDtoRole, TDtoRole, UInt32, TEntryFilter>;
      const aModalProc: TFunc<Integer>);
    procedure OpenCrudTenant(const aTenantUI: ICrudUI<TDtoTenant, TDtoTenant, UInt8, TVoid>;
      const aModalProc: TFunc<Integer>);

    function IsCrudPersonActivated: Boolean;
    function IsCrudUnitActivated: Boolean;

    procedure OpenReportClubMembers(const aParamsProvider: IParamsProvider<TObject>);
    procedure OpenReportMemberUnits(const aParams: TExporterPersonsParams;
      const aParamsProvider: IParamsProvider<TExporterPersonsParams>);
    procedure OpenReportPersons(const aParams: TExporterPersonsParams;
      const aParamsProvider: IParamsProvider<TExporterPersonsParams>);
    procedure OpenReportUnitMembers(const aParams: TExporterUnitMembersParams;
      const aParamsProvider: IParamsProvider<TExporterUnitMembersParams>);
    procedure OpenReportUnitRoles(const aParamsProvider: IParamsProvider<TObject>);
    procedure OpenReportBirthdays(const aParamsProvider: IParamsProvider<TExporterBirthdaysParams>);
  end;

implementation

end.
