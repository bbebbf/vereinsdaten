unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, System.Actions, Vcl.ActnList,
  unPerson, SqlConnection, ProgressIndicator, PersonBusinessIntf, PersonBusiness;

type
  TfmMain = class(TForm)
    MainMenu: TMainMenu;
    Stammdaten1: TMenuItem;
    StatusBar: TStatusBar;
    ActionList: TActionList;
    acMasterdataAddress: TAction;
    acMasterdataUnit: TAction;
    acMasterdataRole: TAction;
    Adressenbearbeiten1: TMenuItem;
    Einheitenbearbeiten1: TMenuItem;
    Rollenbearbeiten1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure acMasterdataUnitExecute(Sender: TObject);
    procedure acMasterdataRoleExecute(Sender: TObject);
    procedure acMasterdataAddressExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fConnection: ISqlConnection;
    fProgressIndicator: IProgressIndicator;
    fPersonBusinessIntf: IPersonBusinessIntf;
    ffraPerson: TfraPerson;
  public
    property Connection: ISqlConnection read fConnection write fConnection;
    property ProgressIndicator: IProgressIndicator read fProgressIndicator write fProgressIndicator;
  end;

var
  fmMain: TfmMain;

implementation

uses Vdm.Globals, ConfigReader, unUnit, CrudCommands, CrudBusiness, EntryCrudConfig,
  DtoUnit, DtoUnitAggregated, CrudConfigUnitAggregated, DtoRole, CrudConfigRoleEntry, unRole,
  DtoAddress, DtoAddressAggregated, unAddress, CrudConfigAddressAggregated;

{$R *.dfm}

procedure TfmMain.acMasterdataAddressExecute(Sender: TObject);
begin
  var lDialog := TfmAddress.Create(Self);
  try
    var lCrudConfig: IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32> := TCrudConfigAddressAggregated.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32> := TCrudBusiness<TDtoAddressAggregated, TDtoAddress, UInt32>.Create(lDialog, lCrudConfig);
    lBusiness.Initialize;
    lDialog.ShowModal;
    if lBusiness.DataChanged then
    begin
      fPersonBusinessIntf.ClearAddressCache;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataRoleExecute(Sender: TObject);
begin
  var lDialog := TfmRole.Create(Self);
  try
    var lCrudConfig: IEntryCrudConfig<TDtoRole, TDtoRole, UInt32> := TCrudConfigRoleEntry.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32> := TCrudBusiness<TDtoRole, TDtoRole, UInt32>.Create(lDialog, lCrudConfig);
    lBusiness.Initialize;
    lDialog.ShowModal;
    if lBusiness.DataChanged then
    begin
      fPersonBusinessIntf.ClearUnitCache;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataUnitExecute(Sender: TObject);
begin
  var lDialog := TfmUnit.Create(Self);
  try
    var lCrudConfig: IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32> := TCrudConfigUnitAggregated.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32> := TCrudBusiness<TDtoUnitAggregated, TDtoUnit, UInt32>.Create(lDialog, lCrudConfig);
    lBusiness.Initialize;
    lDialog.ShowModal;
    if lBusiness.DataChanged then
    begin
      fPersonBusinessIntf.ClearUnitCache;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;

  fActivated := True;
  fPersonBusinessIntf := TPersonBusiness.Create(fConnection, ffraPerson, fProgressIndicator);
  fPersonBusinessIntf.Initialize;
  fPersonBusinessIntf.LoadList;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Caption := TVdmGlobals.GetVdmApplicationTitle;

  var lConnectionInfo := 'Server: ' + TConfigReader.Instance.Connection.Host +
    ':' + IntToStr(TConfigReader.Instance.Connection.Port);
  if Length(TConfigReader.Instance.Connection.SshRemoteHost) > 0 then
    lConnectionInfo := 'Remote Host: ' + TConfigReader.Instance.Connection.SshRemoteHost + ' / ' + lConnectionInfo;
  StatusBar.SimpleText := lConnectionInfo;

  ffraPerson := TfraPerson.Create(Self);
  ffraPerson.Parent := Self;
  ffraPerson.Align := TAlign.alClient;
  ffraPerson.Show;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fPersonBusinessIntf := nil;
  fProgressIndicator := nil;
  fConnection := nil;
end;

end.
