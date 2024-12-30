program vdm;

uses
  {$ifdef FASTMM}
  FastMM4,
  {$endif FASTMM}
  Vcl.Forms,
  FireDAC.VCLUI.Wait,
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
  ListviewAttachedData in 'view\tools\ListviewAttachedData.pas',
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
  ProgressIndicator in 'general\intf\tools\ProgressIndicator.pas',
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
  unPersonMemberOf in 'view\frames\unPersonMemberOf.pas' {fraPersonMemberOf: TFrame},
  ListCrudCommands in 'general\common\Crud\ListCrudCommands.pas',
  FilterSelect in 'general\common\Db\FilterSelect.pas',
  ListEnumerator in 'general\intf\tools\ListEnumerator.pas',
  PersonMemberOfUI in 'view\intf\PersonMemberOfUI.pas',
  DtoMemberAggregated in 'data\DtoMemberAggregated.pas',
  MemberOfBusinessIntf in 'business\intf\MemberOfBusinessIntf.pas',
  MemberOfBusiness in 'business\impl\MemberOfBusiness.pas',
  CrudMemberConfig in 'data\CrudMemberConfig.pas',
  SelectRecord in 'general\intf\sql\SelectRecord.pas',
  Vdm.Types in 'general\Vdm.Types.pas',
  SelectList in 'general\intf\sql\SelectList.pas',
  SelectListFilter in 'general\intf\sql\SelectListFilter.pas',
  CrudConfigUnit in 'data\CrudConfigUnit.pas',
  CrudConfigRole in 'data\CrudConfigRole.pas',
  unPersonMemberOfsEditDlg in 'view\forms\unPersonMemberOfsEditDlg.pas' {fmPersonMemberOfsEditDlg},
  DelayedExecute in 'general\common\Tools\DelayedExecute.pas',
  CheckboxDatetimePickerHandler in 'view\tools\CheckboxDatetimePickerHandler.pas',
  KeyIndexStrings in 'general\common\Tools\KeyIndexStrings.pas',
  LazyLoader in 'general\common\Tools\LazyLoader.pas',
  ValueConverter in 'general\intf\tools\ValueConverter.pas',
  ListCrudCommands.Types in 'general\common\Crud\ListCrudCommands.Types.pas',
  DtoUnitAggregated in 'data\DtoUnitAggregated.pas',
  DelegatedConverter in 'general\common\Tools\DelegatedConverter.pas',
  CrudBusiness in 'business\impl\CrudBusiness.pas',
  EntryCrudConfig in 'general\intf\crud\EntryCrudConfig.pas',
  unUnit in 'view\forms\unUnit.pas' {fmUnit},
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
  VclUITools in 'view\tools\VclUITools.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  var lConnectProgress := TfmProgressForm.Create(Application);
  try
    lConnectProgress.ProgressBegin(0, False, 'Datenbankverbindung wird hergestellt ...');
    var lConnection := TConnectionFactory.CreateConnection;
    if not lConnection.Connect then
      Exit;
    lConnectProgress.ProgressEnd;

    fmMain.Connection := lConnection;
    fmMain.ProgressIndicator := lConnectProgress;
    Application.Run;
  finally
    lConnectProgress.Free;
  end;
end.
