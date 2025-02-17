unit MainBusiness;

interface

uses System.SysUtils, InterfacedBase, MainBusinessIntf, SqlConnection, MainUI, PersonBusinessIntf, EntryCrudConfig,
  CrudCommands, Vdm.Types, CrudUI, DtoUnit, DtoUnitAggregated, DtoAddress, DtoAddressAggregated, DtoRole, DtoTenant;

type
  TMainBusiness = class(TInterfacedBase, IMainBusiness)
  strict private
    fConnection: ISqlConnection;
    fUI: IMainUI;
    fPersonBusinessIntf: IPersonBusinessIntf;
    fCrudConfigUnit: IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>;
    fBusinessUnit: ICrudCommands<UInt32, TUnitFilter>;

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
  public
    constructor Create(const aConnection: ISqlConnection; const aMainUI: IMainUI);
  end;

implementation

uses Vdm.Globals, ConfigReader, TenantReader, RoleMapper, UnitMapper, PersonMapper, PersonBusiness,
  CrudBusiness, CrudConfigUnitAggregated, CrudConfigAddressAggregated, CrudConfigRoleEntry, CrudConfigTenantEntry,
  Report.ClubMembers, Report.UnitMembers, Report.UnitRoles, Report.MemberUnits, Report.Persons;

{ TMainBusiness }

constructor TMainBusiness.Create(const aConnection: ISqlConnection; const aMainUI: IMainUI);
begin
  inherited Create;
  fConnection := aConnection;
  fUI := aMainUI;

  fPersonBusinessIntf := TPersonBusiness.Create(fConnection, fUI.GetPersonAggregatedUI, fUI.GetProgressIndicator);
  fPersonBusinessIntf.Initialize;

  fCrudConfigUnit := TCrudConfigUnitAggregated.Create(fConnection, fUI.GetUnitMemberOfsUI, fUi.GetProgressIndicator);
  fBusinessUnit := TCrudBusiness<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>.Create(fUI.GetUnitCrudUI, fCrudConfigUnit);
  fBusinessUnit.Initialize;
end;

procedure TMainBusiness.Initialize;
begin
  TTenantReader.Connection := fConnection;
  TRoleMapper.Connection := fConnection;
  TUnitMapper.Connection := fConnection;
  TPersonMapper.Connection := fConnection;
  fUI.SetBusiness(Self);
  fUI.SetApplicationTitle(TVdmGlobals.GetVdmApplicationTitle + ': ' + TTenantReader.Instance.Tenant.Title);
  fUI.SetConfiguration(TConfigReader.Instance.Connection);
end;

procedure TMainBusiness.OpenCrudAddress(const aAdressUI: ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>;
  const aModalProc: TFunc<Integer>);
begin
  var lCrudConfig: IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid> := TCrudConfigAddressAggregated.Create(fConnection);
  var lBusiness: ICrudCommands<UInt32, TVoid> := TCrudBusiness<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>.Create(aAdressUI, lCrudConfig);
  lBusiness.Initialize;
  aModalProc;
  if lBusiness.DataChanged then
  begin
    fPersonBusinessIntf.ClearAddressCache;
  end;
end;

procedure TMainBusiness.OpenCrudRole(const aRoleUI: ICrudUI<TDtoRole, TDtoRole, UInt32, TVoid>;
  const aModalProc: TFunc<Integer>);
begin
  var lCrudConfig: IEntryCrudConfig<TDtoRole, TDtoRole, UInt32, TVoid> := TCrudConfigRoleEntry.Create(fConnection);
  var lBusiness: ICrudCommands<UInt32, TVoid> := TCrudBusiness<TDtoRole, TDtoRole, UInt32, TVoid>.Create(aRoleUI, lCrudConfig);
  lBusiness.Initialize;
  aModalProc;
  if lBusiness.DataChanged then
  begin
    TRoleMapper.Invalidate;
  end;
end;

procedure TMainBusiness.OpenCrudTenant(const aTenantUI: ICrudUI<TDtoTenant, TDtoTenant, UInt8, TVoid>;
  const aModalProc: TFunc<Integer>);
begin
  var lCrudConfig: IEntryCrudConfig<TDtoTenant, TDtoTenant, UInt8, TVoid> := TCrudConfigTenantEntry.Create(fConnection);
  var lBusiness: ICrudCommands<UInt8, TVoid> := TCrudBusiness<TDtoTenant, TDtoTenant, UInt8, TVoid>.Create(aTenantUI, lCrudConfig);
  lBusiness.Initialize;
  aModalProc;
  if lBusiness.DataChanged then
  begin
    TTenantReader.Invalidate;
    fUI.SetApplicationTitle(TVdmGlobals.GetVdmApplicationTitle + ': ' + TTenantReader.Instance.Tenant.Title);
  end;
end;

procedure TMainBusiness.OpenReportClubMembers;
begin
  var lReport := TfmReportClubMembers.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportMemberUnits;
begin
  var lReport := TfmReportMemberUnits.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportPersons;
begin
  var lReport := TfmReportPersons.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportUnitMembers;
begin
  var lReport := TfmReportUnitMembers.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportUnitRoles;
begin
  var lReport := TfmReportUnitRoles.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.SwitchedFromPersonsToUnitsCrud;
begin
  TPersonMapper.Invalidate;
  fBusinessUnit.LoadList;
end;

procedure TMainBusiness.SwitchedFromUnitsToPersonsCrud;
begin
  TUnitMapper.Invalidate;
  fPersonBusinessIntf.LoadList;
end;

procedure TMainBusiness.UIIsReady;
begin
  fPersonBusinessIntf.LoadList;
end;

end.
