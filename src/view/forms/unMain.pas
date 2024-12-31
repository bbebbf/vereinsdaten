unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, System.Actions, Vcl.ActnList,
  unPerson, SqlConnection, ProgressIndicator, PersonBusinessIntf, PersonBusiness, Vcl.ExtCtrls;

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
    shaTestConnectionWarning: TShape;
    Berichte1: TMenuItem;
    miReportClubMembers: TMenuItem;
    acReportClubMembers: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure acMasterdataUnitExecute(Sender: TObject);
    procedure acMasterdataRoleExecute(Sender: TObject);
    procedure acMasterdataAddressExecute(Sender: TObject);
    procedure acReportClubMembersExecute(Sender: TObject);
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

uses System.UITypes, Vdm.Globals, ConfigReader, unUnit, CrudCommands, CrudBusiness, EntryCrudConfig,
  DtoUnit, DtoUnitAggregated, CrudConfigUnitAggregated, DtoRole, CrudConfigRoleEntry, unRole,
  DtoAddress, DtoAddressAggregated, unAddress, CrudConfigAddressAggregated, Vdm.Types,
  Report.ClubMembers, TenantReader;

{$R *.dfm}

procedure TfmMain.acMasterdataAddressExecute(Sender: TObject);
begin
  var lDialog := TfmAddress.Create(Self);
  try
    var lCrudConfig: IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid> := TCrudConfigAddressAggregated.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32, TVoid> := TCrudBusiness<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>.Create(lDialog, lCrudConfig);
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
    var lCrudConfig: IEntryCrudConfig<TDtoRole, TDtoRole, UInt32, TVoid> := TCrudConfigRoleEntry.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32, TVoid> := TCrudBusiness<TDtoRole, TDtoRole, UInt32, TVoid>.Create(lDialog, lCrudConfig);
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
    var lCrudConfig: IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter> := TCrudConfigUnitAggregated.Create(fConnection);
    var lBusiness: ICrudCommands<UInt32, TUnitFilter> := TCrudBusiness<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>.Create(lDialog, lCrudConfig);
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

procedure TfmMain.acReportClubMembersExecute(Sender: TObject);
begin
  var lReport := TfmReportClubMembers.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;

  Caption := TVdmGlobals.GetVdmApplicationTitle + ': ' + TTenantReader.Instance.Tenant.Title;

  fActivated := True;
  fPersonBusinessIntf := TPersonBusiness.Create(fConnection, ffraPerson, fProgressIndicator);
  fPersonBusinessIntf.Initialize;
  fPersonBusinessIntf.LoadList;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Caption := TVdmGlobals.GetVdmApplicationTitle;

  shaTestConnectionWarning.Visible := TConfigReader.Instance.Connection.ShapeVisible;
  if shaTestConnectionWarning.Visible then
  begin
    var lColor: TColor;
    if not TryStringToColor('$' + TConfigReader.Instance.Connection.ShapeColor, lColor) then
      lColor := TColorRec.SysHighlight;
    shaTestConnectionWarning.Brush.Color := lColor;
  end;

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
