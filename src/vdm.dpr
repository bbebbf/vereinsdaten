program vdm;

uses
  {$ifdef FASTMM}
  FastMM4,
  {$endif}
  Vcl.Forms,
  Vcl.Dialogs,
  FireDAC.VCLUI.Wait,
  Winapi.Windows,
  SqlConnection in 'general\intf\sql\SqlConnection.pas',
  Transaction in 'general\intf\transcation\Transaction.pas',
  MySqlConnection in 'general\common\MySql\MySqlConnection.pas',
  CrudUI in 'general\intf\crud\CrudUI.pas',
  CrudCommands in 'general\intf\crud\CrudCommands.pas',
  CrudAccessor in 'general\common\Crud\CrudAccessor.pas',
  StringTools in 'general\common\Tools\StringTools.pas',
  CrudConfig in 'general\intf\crud\CrudConfig.pas',
  DtoPerson in 'data\DtoPerson.pas',
  CrudConfigPerson in 'data\CrudConfigPerson.pas',
  ConnectionFactory in 'general\common\Db\ConnectionFactory.pas',
  DtoAddress in 'data\DtoAddress.pas',
  CrudConfigAddress in 'data\CrudConfigAddress.pas',
  KeyMapper in 'general\common\Tools\KeyMapper.pas',
  KeyIndexMapper in 'general\common\Tools\KeyIndexMapper.pas',
  CrudConfigPersonAddress in 'data\CrudConfigPersonAddress.pas',
  DtoPersonAddress in 'data\DtoPersonAddress.pas',
  DtoPersonAggregated in 'data\DtoPersonAggregated.pas',
  PersonAggregatedUI in 'view\intf\PersonAggregatedUI.pas',
  PersonBusinessIntf in 'business\intf\PersonBusinessIntf.pas',
  PersonBusiness in 'business\impl\PersonBusiness.pas',
  RecordActions in 'general\common\Tools\RecordActions.pas',
  ConfigReader in 'general\common\Tools\ConfigReader.pas',
  unPerson in 'view\frames\unPerson.pas' {fraPerson},
  DtoClubmembership in 'data\DtoClubmembership.pas',
  CrudConfigClubmembership in 'data\CrudConfigClubmembership.pas',
  Vdm.Globals in 'general\Vdm.Globals.pas',
  FileTools in 'general\common\Tools\FileTools.pas',
  ProgressIndicatorIntf in 'general\intf\tools\ProgressIndicatorIntf.pas',
  unProgressForm in 'view\forms\unProgressForm.pas' {fmProgressForm},
  ComponentValueChangedObserver in 'view\tools\ComponentValueChangedObserver.pas',
  ClubmembershipTools in 'data\ClubmembershipTools.pas',
  MessageDialogs in 'view\tools\MessageDialogs.pas',
  WindowsProcess in 'general\common\Tools\WindowsProcess.pas',
  WindowsProcess.Tools in 'general\common\Tools\WindowsProcess.Tools.pas',
  WindowsRunningProcesses in 'general\common\Tools\WindowsRunningProcesses.pas',
  SshTunnel in 'general\common\Tools\SshTunnel.pas',
  SshTunnelSqlConnection in 'general\common\SshTunnelSql\SshTunnelSqlConnection.pas',
  DtoMember in 'data\DtoMember.pas',
  DtoRole in 'data\DtoRole.pas',
  DtoUnit in 'data\DtoUnit.pas',
  ListSelector in 'general\common\Db\ListSelector.pas',
  unMemberOf in 'view\frames\unMemberOf.pas' {fraMemberOf: TFrame},
  ListCrudCommands in 'general\common\Crud\ListCrudCommands.pas',
  FilterSelect in 'general\common\Db\FilterSelect.pas',
  ListEnumerator in 'general\intf\tools\ListEnumerator.pas',
  MemberOfUI in 'view\intf\MemberOfUI.pas',
  DtoMemberAggregated in 'data\DtoMemberAggregated.pas',
  MemberOfBusinessIntf in 'business\intf\MemberOfBusinessIntf.pas',
  MemberOfBusiness in 'business\impl\MemberOfBusiness.pas',
  CrudMemberConfigBase in 'data\CrudMemberConfigBase.pas',
  SelectRecord in 'general\intf\sql\SelectRecord.pas',
  Vdm.Types in 'general\Vdm.Types.pas',
  SelectList in 'general\intf\sql\SelectList.pas',
  SelectListFilter in 'general\intf\sql\SelectListFilter.pas',
  CrudConfigUnit in 'data\CrudConfigUnit.pas',
  CrudConfigRole in 'data\CrudConfigRole.pas',
  unMemberOfsEditDlg in 'view\forms\unMemberOfsEditDlg.pas' {fmMemberOfsEditDlg},
  DelayedExecute in 'general\common\Tools\DelayedExecute.pas',
  KeyIndexStrings in 'general\common\Tools\KeyIndexStrings.pas',
  LazyLoader in 'general\common\Tools\LazyLoader.pas',
  ValueConverter in 'general\intf\tools\ValueConverter.pas',
  ListCrudCommands.Types in 'general\common\Crud\ListCrudCommands.Types.pas',
  DtoUnitAggregated in 'data\DtoUnitAggregated.pas',
  DelegatedConverter in 'general\common\Tools\DelegatedConverter.pas',
  CrudBusiness in 'business\impl\CrudBusiness.pas',
  EntryCrudConfig in 'general\intf\crud\EntryCrudConfig.pas',
  CrudConfigUnitAggregated in 'data\CrudConfigUnitAggregated.pas',
  InterfacedBase in 'general\common\Tools\InterfacedBase.pas',
  unMain in 'view\forms\unMain.pas' {fmMain},
  unRole in 'view\forms\unRole.pas' {fmRole},
  CrudConfigRoleEntry in 'data\CrudConfigRoleEntry.pas',
  DtoPersonNameId in 'data\DtoPersonNameId.pas',
  DtoAddressAggregated in 'data\DtoAddressAggregated.pas',
  CrudConfigAddressAggregated in 'data\CrudConfigAddressAggregated.pas',
  unAddress in 'view\forms\unAddress.pas' {fmAddress},
  RecordActionsVersioning in 'general\common\Tools\RecordActionsVersioning.pas',
  Vdm.Versioning.Types in 'general\Vdm.Versioning.Types.pas',
  VersionInfoAccessor in 'general\common\Tools\VersionInfoAccessor.pas',
  VersionInfoEntryUI in 'general\intf\tools\VersionInfoEntryUI.pas',
  VclUITools in 'view\tools\VclUITools.pas',
  VersionInfoEntryAccessor in 'general\intf\tools\VersionInfoEntryAccessor.pas',
  Report.ClubMembers in 'reports\Report.ClubMembers.pas' {fmReportClubMembers},
  TenantReader in 'general\common\Tools\TenantReader.pas',
  DtoTenant in 'data\DtoTenant.pas',
  Report.UnitMembers in 'reports\Report.UnitMembers.pas' {fmReportUnitMembers},
  unTenant in 'view\forms\unTenant.pas' {fmTenant},
  CrudConfigTenant in 'data\CrudConfigTenant.pas',
  CrudConfigTenantEntry in 'data\CrudConfigTenantEntry.pas',
  Report.UnitRoles in 'reports\Report.UnitRoles.pas' {fmReportUnitRoles},
  ExtendedListview in 'view\tools\ExtendedListview.pas',
  unUnit in 'view\frames\unUnit.pas' {fraUnit: TFrame},
  Report.MemberUnits in 'reports\Report.MemberUnits.pas' {fmReportMemberUnits},
  unSelectConnection in 'view\forms\unSelectConnection.pas' {fmSelectConnection},
  Report.Persons in 'reports\Report.Persons.pas' {fmReportPersons},
  CrudMemberConfigMasterPerson in 'data\CrudMemberConfigMasterPerson.pas',
  MemberOfConfigIntf in 'business\intf\MemberOfConfigIntf.pas',
  CrudMemberConfigMasterUnit in 'data\CrudMemberConfigMasterUnit.pas',
  EntriesCrudEvents in 'general\intf\crud\EntriesCrudEvents.pas',
  MemberOfVersionInfoConfig in 'business\impl\MemberOfVersionInfoConfig.pas',
  ProgressUI in 'general\intf\tools\ProgressUI.pas',
  ProgressIndicator in 'general\common\Tools\ProgressIndicator.pas',
  Singleton in 'general\common\Tools\Singleton.pas',
  RoleMapper in 'business\impl\RoleMapper.pas',
  UnitMapper in 'business\impl\UnitMapper.pas',
  PersonMapper in 'business\impl\PersonMapper.pas',
  MainBusinessIntf in 'business\intf\MainBusinessIntf.pas',
  MainBusiness in 'business\impl\MainBusiness.pas',
  MainUI in 'view\intf\MainUI.pas',
  ActionlistWrapper in 'view\tools\ActionlistWrapper.pas',
  WorkSection in 'general\intf\tools\WorkSection.pas',
  Report.OneUnitMembers in 'reports\Report.OneUnitMembers.pas' {fmReportOneUnitMembers},
  Report.Birthdays in 'reports\Report.Birthdays.pas' {fmReportBirthdays},
  Nullable in 'general\common\Tools\Nullable.pas',
  Helper.ConstraintControls in 'view\tools\Helper.ConstraintControls.pas',
  ValidatableValueControlsRegistry in 'view\tools\ValidatableValueControlsRegistry.pas',
  Helper.Frame in 'view\tools\Helper.Frame.pas',
  Exporter.Base in 'export\Exporter.Base.pas',
  Exporter.UnitMembers in 'export\Exporter.UnitMembers.pas',
  Exporter.Birthdays in 'export\Exporter.Birthdays.pas',
  Exporter.TargetIntf in 'export\Exporter.TargetIntf.pas',
  Exporter.ClubMembers in 'export\Exporter.ClubMembers.pas',
  Exporter.MemberUnits in 'export\Exporter.MemberUnits.pas',
  Exporter.OneUnitMembers in 'export\Exporter.OneUnitMembers.pas',
  Exporter.UnitRoles in 'export\Exporter.UnitRoles.pas',
  Exporter.Persons in 'export\Exporter.Persons.pas',
  Joiner in 'general\common\Tools\Joiner.pas',
  ParamsProvider in 'general\intf\tools\ParamsProvider.pas',
  unParamsDlg in 'view\forms\unParamsDlg.pas' {fmParamsDlg},
  unExporter.Params.UnitMember in 'view\forms\export\unExporter.Params.UnitMember.pas' {fmExporterParamsUnitMember},
  unExporter.Params.Birthdays in 'view\forms\export\unExporter.Params.Birthdays.pas' {fmExporterParamsBirthdays},
  Exporter.Birthdays.Types in 'export\Exporter.Birthdays.Types.pas',
  Exporter.UnitMembers.Types in 'export\Exporter.UnitMembers.Types.pas',
  Exporter.Persons.Types in 'export\Exporter.Persons.Types.pas',
  unExporter.Params.Persons in 'view\forms\export\unExporter.Params.Persons.pas' {fmExporterParamsPersons},
  Report.Base in 'reports\Report.Base.pas' {fmReportBase},
  unExporter.Params.Base in 'view\forms\export\unExporter.Params.Base.pas' {fmExporterParamsBase},
  PatternValidation in 'general\common\Tools\PatternValidation.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := TVdmGlobals.GetVdmApplicationTitle;
  var lJobObjectHandle: THandle := 0;
  try
    {$ifdef FASTMM}
    // only to proof that FastMM works.
    TObject.Create;
    {$else}
    // FastMM has a problem with job objects.
    lJobObjectHandle := CreateJobObject(nil, nil);
    var lJobLimitInfo := default(JOBOBJECT_EXTENDED_LIMIT_INFORMATION);
    lJobLimitInfo.BasicLimitInformation.LimitFlags := JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE;
    SetInformationJobObject(lJobObjectHandle, JobObjectExtendedLimitInformation, @lJobLimitInfo, SizeOf(lJobLimitInfo));
    AssignProcessToJobObject(lJobObjectHandle, GetCurrentProcess);
    {$endif}
    Application.CreateForm(TfmMain, fmMain);

    var lConnectionCount := TConfigReader.Instance.ConnectionNames.Count;
    if lConnectionCount = 0 then
    begin
      TMessageDialogs.Ok('Keine Verbindungsdefinitionen gefunden. Programm wird beendet.', TMsgDlgType.mtError);
      Exit;
    end
    else if lConnectionCount > 1 then
    begin
      var lDialog := TfmSelectConnection.Create(Application);
      try
        if not lDialog.Execute then
          Exit;
      finally
        lDialog.Free;
      end;
    end;

    var lConnectProgressUI := TfmProgressForm.Create(Application);
    try
      var lProgressIndicator := TProgressIndicator.Create(lConnectProgressUI);
      var lProgress := TProgress.New(lProgressIndicator, 0, 'Datenbankverbindung wird hergestellt ...');
      var lConnection := TConnectionFactory.CreateConnection;
      try
        lConnection.Connect;
        lProgress := nil;
      except
        lProgress := nil;
        TMessageDialogs.Ok('Verbindung zur Datenbank ist fehlgeschlagen. Das Programm wird beendet.', TMsgDlgType.mtError);
        Exit;
      end;
      var lMainBusiness: IMainBusiness := TMainBusiness.Create(lConnection, fmMain);
      lMainBusiness.Initialize;
    finally
      lConnectProgressUI.Free;
    end;

    Application.Run;
  finally
    if lJobObjectHandle > 0 then
      CloseHandle(lJobObjectHandle);
  end;
end.
