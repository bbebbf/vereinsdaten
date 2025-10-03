unit MainBusiness;

interface

uses System.SysUtils, InterfacedBase, MainBusinessIntf, SqlConnection, MainUI, PersonBusinessIntf, EntryCrudConfig,
  CrudCommands, Vdm.Types, CrudUI, DtoUnit, DtoUnitAggregated, DtoAddress, DtoAddressAggregated, DtoRole, DtoTenant,
  ParamsProvider, Exporter.Persons.Types, Exporter.UnitMembers.Types, Exporter.Birthdays.Types;

type
  TMainBusiness = class(TInterfacedBase, IMainBusiness)
  strict private
    fConnection: ISqlConnection;
    fUI: IMainUI;
    fPersonBusinessIntf: IPersonBusinessIntf;
    fCrudConfigUnit: IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TEntryFilter>;
    fBusinessUnit: ICrudCommands<UInt32, TEntryFilter>;
    fCrudPersonActivated: Boolean;
    fCrudUnitActivated: Boolean;

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
  public
    constructor Create(const aConnection: ISqlConnection; const aMainUI: IMainUI);
  end;

implementation

uses Vdm.Globals, ConfigReader, TenantReader, RoleMapper, UnitMapper, PersonMapper, PersonBusiness, WorkSection,
  CrudBusiness, CrudConfigUnitAggregated, CrudConfigAddressAggregated, CrudConfigRoleEntry, CrudConfigTenantEntry

  , Exporter.Types
  , Exporter.Persons, Report.Persons.Printout, Report.Persons.Csv
  , Exporter.UnitMembers, Report.UnitMembers.Printout, Report.UnitMembers.Csv
  , Exporter.UnitRoles, Report.UnitRoles.Printout, Report.UnitRoles.Csv
  , Exporter.OneUnitMembers, Report.OneUnitMembers.Printout, Report.OneUnitMembers.Csv
  , Exporter.Birthdays, Report.Birthdays.Printout, Report.Birthdays.Csv
  , Exporter.ClubMembers, Report.ClubMembers.Printout, Report.ClubMembers.Csv
  , Exporter.MemberUnits, Report.MemberUnits.Printout, Report.MemberUnits.Csv
  ;

{ TMainBusiness }

constructor TMainBusiness.Create(const aConnection: ISqlConnection; const aMainUI: IMainUI);
begin
  inherited Create;
  fConnection := aConnection;
  fUI := aMainUI;

  fPersonBusinessIntf := TPersonBusiness.Create(fConnection, fUI.GetPersonAggregatedUI, fUI.GetProgressIndicator,
    procedure(Id: UInt32)
    begin
      OpenCrudUnit(Id);
    end
  );
  fPersonBusinessIntf.Initialize;

  fCrudConfigUnit := TCrudConfigUnitAggregated.Create(fConnection, fUI.GetUnitMemberOfsUI, fUi.GetProgressIndicator,
    procedure(Id: UInt32)
    begin
      OpenCrudPerson(Id);
    end
  );
  fBusinessUnit := TCrudBusiness<TDtoUnitAggregated, TDtoUnit, UInt32, TEntryFilter>.Create(fUI.GetUnitCrudUI, fCrudConfigUnit);
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

function TMainBusiness.IsCrudPersonActivated: Boolean;
begin
  Result := fCrudPersonActivated;
end;

function TMainBusiness.IsCrudUnitActivated: Boolean;
begin
  Result := fCrudUnitActivated;
end;

procedure TMainBusiness.OpenCrudAddress(const aAdressUI: ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TEntryFilter>;
  const aModalProc: TFunc<Integer>);
begin
  var lCrudConfig: IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32, TEntryFilter> := TCrudConfigAddressAggregated.Create(fConnection);
  var lBusiness: ICrudCommands<UInt32, TEntryFilter> := TCrudBusiness<TDtoAddressAggregated, TDtoAddress, UInt32, TEntryFilter>.Create(aAdressUI, lCrudConfig);
  lBusiness.Initialize;
  aModalProc;
  if lBusiness.DataChanged then
  begin
    fPersonBusinessIntf.ClearAddressCache;
  end;
end;

procedure TMainBusiness.OpenCrudPerson(const aPersonId: UInt32);
begin
  var lWorkSectionPerson: IWorkSection;
  Supports(fUI.GetPersonAggregatedUI, IWorkSection, lWorkSectionPerson);
  var lWorkSectionUnit: IWorkSection;
  Supports(fUI.GetUnitCrudUI, IWorkSection, lWorkSectionUnit);

  lWorkSectionUnit.EndWork;
  TUnitMapper.Invalidate;
  lWorkSectionPerson.BeginWork;
  fPersonBusinessIntf.LoadList;
  if aPersonId > 0 then
    fPersonBusinessIntf.SetSelectedEntry(aPersonId);

  fCrudPersonActivated := True;
  fCrudUnitActivated := False;
  fUI.UpdateMainActions;
end;

procedure TMainBusiness.OpenCrudRole(const aRoleUI: ICrudUI<TDtoRole, TDtoRole, UInt32, TEntryFilter>;
  const aModalProc: TFunc<Integer>);
begin
  var lCrudConfig: IEntryCrudConfig<TDtoRole, TDtoRole, UInt32, TEntryFilter> := TCrudConfigRoleEntry.Create(fConnection);
  var lBusiness: ICrudCommands<UInt32, TEntryFilter> := TCrudBusiness<TDtoRole, TDtoRole, UInt32, TEntryFilter>.Create(aRoleUI, lCrudConfig);
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

procedure TMainBusiness.OpenCrudUnit(const aUnitId: UInt32);
begin
  var lWorkSectionPerson: IWorkSection;
  Supports(fUI.GetPersonAggregatedUI, IWorkSection, lWorkSectionPerson);
  var lWorkSectionUnit: IWorkSection;
  Supports(fUI.GetUnitCrudUI, IWorkSection, lWorkSectionUnit);

  lWorkSectionPerson.EndWork;
  TPersonMapper.Invalidate;
  lWorkSectionUnit.BeginWork;
  fBusinessUnit.LoadList;
  if aUnitId > 0 then
    fBusinessUnit.SetSelectedEntry(aUnitId);

  fCrudUnitActivated := True;
  fCrudPersonActivated := False;
  fUI.UpdateMainActions;
end;

procedure TMainBusiness.OpenReportBirthdays(const aParamsProvider: IParamsProvider<TExporterBirthdaysParams>);
begin
  var lExporter: TExporterBirthdays := nil;
  var lParams: TExporterBirthdaysParams := nil;
  var lReport := TfmReportBirthdaysPrintout.Create;
  try
    lParams := TExporterBirthdaysParams.Create;
    lParams.FromDate := Now;
    lParams.ToDate := Now + 21;
    lParams.ConsiderBirthdaylistFlag := True;

    lExporter := TExporterBirthdays.Create(fConnection);
    lExporter.Targets.Add(lReport);
    lExporter.Targets.Add(TReportBirthdaysCsv.Create);
    lExporter.Params := lParams;
    lExporter.ParamsProvider := aParamsProvider;
    lExporter.DoExport;
  finally
    lExporter.Free;
    lParams.Free;
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportClubMembers(const aParamsProvider: IParamsProvider<TObject>);
begin
  var lReport := TfmReportClubMembersPrintout.Create;
  try
    var lExporter := TExporterClubMembers.Create(fConnection);
    try
      lExporter.Targets.Add(lReport);
      lExporter.Targets.Add(TReportClubMembersCsv.Create);
      lExporter.ParamsProvider := aParamsProvider;
      lExporter.DoExport;
    finally
      lExporter.Free;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportMemberUnits(const aParams: TExporterPersonsParams;
      const aParamsProvider: IParamsProvider<TExporterPersonsParams>);
begin
  var lReport := TfmReportMemberUnitsPrintout.Create;
  try
    var lExporter := TExporterMemberUnits.Create(fConnection);
    try
      lExporter.Targets.Add(lReport);
      lExporter.Targets.Add(TReportMemberUnitsCsv.Create);
      lExporter.Params := aParams;
      lExporter.ParamsProvider := aParamsProvider;
      lExporter.DoExport;
    finally
      lExporter.Free;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportPersons(const aParams: TExporterPersonsParams;
  const aParamsProvider: IParamsProvider<TExporterPersonsParams>);
begin
  var lReport := TfmReportPersonsPrintout.Create;
  try
    var lExporter := TExporterPersons.Create(fConnection);
    try
      lExporter.Targets.Add(lReport);
      lExporter.Targets.Add(TReportPersonsCsv.Create);
      lExporter.Params := aParams;
      lExporter.ParamsProvider := aParamsProvider;
      lExporter.DoExport;
    finally
      lExporter.Free;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportUnitMembers(const aParams: TExporterUnitMembersParams;
  const aParamsProvider: IParamsProvider<TExporterUnitMembersParams>);
begin
  var lReport := TfmReportUnitMembersPrintout.Create;
  try
    var lUnitMembersCsv: IExporterTarget<TExporterUnitMembersParams> := TReportUnitMembersCsv.Create;
    var lExported: Boolean;
    var lSelectedTargetIndex: Integer;
    var lExporter := TExporterUnitMembers.Create(fConnection);
    try
      lExporter.Targets.Add(lReport);
      lExporter.Targets.Add(lUnitMembersCsv);
      lExporter.Params := aParams;
      lExporter.ParamsProvider := aParamsProvider;
      lExported := lExporter.DoExport;
      lSelectedTargetIndex := lExporter.SelectedTargetIndex;
    finally
      lExporter.Free;
    end;
    if not lExported and (aParams.ExportOneUnitDetails > 0) then
    begin
      var lOneUnitMembersCsv: IExporterTarget<TExporterOneUnitMembersParams> := TReportOneUnitMembersCsv.Create;

      var lUnitMembersRequFilePath: IExporterRequiresFilePath;
      Supports(lUnitMembersCsv, IExporterRequiresFilePath, lUnitMembersRequFilePath);
      var lOneUnitMembersRequFilePath: IExporterRequiresFilePath;
      Supports(lOneUnitMembersCsv, IExporterRequiresFilePath, lOneUnitMembersRequFilePath);
      lOneUnitMembersRequFilePath.Assign(lUnitMembersRequFilePath);

      var lResultMessageNotifier: IExporterResultMessageNotifier;
      Supports(aParamsProvider, IExporterResultMessageNotifier, lResultMessageNotifier);

      var lDetailedReport := TfmReportOneUnitMembersPrintout.Create;
      try
        var lDetailedExporter := TExporterOneUnitMembers.Create(fConnection);
        try
          lDetailedExporter.Targets.Add(lDetailedReport);
          lDetailedExporter.Targets.Add(lOneUnitMembersCsv);
          lDetailedExporter.SelectedTargetIndex := lSelectedTargetIndex;
          lDetailedExporter.Params.UnitId := aParams.ExportOneUnitDetails;
          lDetailedExporter.ResultMessageNotifier := lResultMessageNotifier;
          lDetailedExporter.DoExport;
        finally
          lDetailedExporter.Free;
        end;
      finally
        lDetailedReport.Free;
      end;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.OpenReportUnitRoles(const aParamsProvider: IParamsProvider<TObject>);
begin
  var lReport := TfmReportUnitRolesPrintout.Create;
  try
    var lExporter := TExporterUnitRoles.Create(fConnection);
    try
      lExporter.Targets.Add(lReport);
      lExporter.Targets.Add(TReportUnitRolesCsv.Create);
      lExporter.ParamsProvider := aParamsProvider;
      lExporter.DoExport;
    finally
      lExporter.Free;
    end;
  finally
    lReport.Free;
  end;
end;

procedure TMainBusiness.UIIsReady;
begin
  OpenCrudPerson;
end;

end.
