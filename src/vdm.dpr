program vdm;

uses
  Vcl.Forms,
  FireDAC.VCLUI.Wait,
  SqlConnection in 'general\intf\sql\SqlConnection.pas',
  Transaction in 'general\intf\transcation\Transaction.pas',
  MySqlConnection in 'general\common\MySql\MySqlConnection.pas',
  CrudUI in 'general\intf\crud\CrudUI.pas',
  CrudCommands in 'general\intf\crud\CrudCommands.pas',
  DefaultCrudCommands in 'general\common\Crud\DefaultCrudCommands.pas',
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
  MainBusinessIntf in 'business\intf\MainBusinessIntf.pas',
  MainBusiness in 'business\impl\MainBusiness.pas',
  RecordActions in 'general\common\Tools\RecordActions.pas',
  ConfigReader in 'general\common\Tools\ConfigReader.pas',
  unMain in 'view\forms\unMain.pas' {fmMain},
  DtoClubmembership in 'data\DtoClubmembership.pas',
  CrudConfigClubmembership in 'data\CrudConfigClubmembership.pas',
  VdmGlobals in 'general\VdmGlobals.pas',
  FileTools in 'general\common\Tools\FileTools.pas',
  ProgressObserver in 'general\intf\ProgressObserver.pas',
  unProgressForm in 'view\forms\unProgressForm.pas' {fmProgressForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  var lConnectProgress := TfmProgressForm.Create(Application);
  try
    lConnectProgress.ProgressBegin(0, False, 'Datenbankverbing wird hergestellt ...');
    var lConnection := TConnectionFactory.CreateConnection;
    if not lConnection.Connect then
      Exit;

    lConnectProgress.ProgressEnd;
    var lMainBusiness: IMainBusinessIntf := TMainBusiness.Create(lConnection, fmMain);
    lMainBusiness.Initialize;
    Application.Run;
  finally
    lConnectProgress.Free;
  end;
end.
