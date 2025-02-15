unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, System.Actions, Vcl.ActnList,
  unPerson, unUnit, SqlConnection, ProgressIndicatorIntf, PersonBusinessIntf, PersonBusiness,
  DtoUnit, DtoUnitAggregated, CrudConfigUnitAggregated, Vdm.Types, EntryCrudConfig, CrudCommands, Vcl.ExtCtrls,
  unProgressForm;

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
    acReportUnitMembers: TAction;
    EinheitenundPersonen1: TMenuItem;
    acMasterdataTenant: TAction;
    Vereinsdatenbearbeiten1: TMenuItem;
    acReportUnitRoles: TAction;
    RollenundEinheiten1: TMenuItem;
    acReportMemberUnits: TAction;
    acReportMemberUnits1: TMenuItem;
    acReportPersons: TAction;
    Personen1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure acMasterdataUnitExecute(Sender: TObject);
    procedure acMasterdataRoleExecute(Sender: TObject);
    procedure acMasterdataAddressExecute(Sender: TObject);
    procedure acReportClubMembersExecute(Sender: TObject);
    procedure acReportUnitMembersExecute(Sender: TObject);
    procedure acMasterdataTenantExecute(Sender: TObject);
    procedure acReportUnitRolesExecute(Sender: TObject);
    procedure acReportMemberUnitsExecute(Sender: TObject);
    procedure acReportPersonsExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fConnection: ISqlConnection;
    fPersonBusinessIntf: IPersonBusinessIntf;
    ffraPerson: TfraPerson;
    fProgressForm: TfmProgressForm;
    fProgressIndicator: IProgressIndicator;

    fCrudConfigUnit: IEntryCrudConfig<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>;
    fBusinessUnit: ICrudCommands<UInt32, TUnitFilter>;
    ffraUnit: TfraUnit;
  public
    property Connection: ISqlConnection read fConnection write fConnection;
  end;

var
  fmMain: TfmMain;

implementation

uses System.UITypes, Vdm.Globals, ConfigReader, CrudBusiness, DtoRole, CrudConfigRoleEntry, unRole,
  DtoAddress, DtoAddressAggregated, unAddress, CrudConfigAddressAggregated,
  Report.ClubMembers, Report.UnitMembers, TenantReader, DtoTenant, CrudConfigTenantEntry, unTenant,
  Report.UnitRoles, Report.MemberUnits, Report.Persons, ProgressIndicator, RoleMapper, UnitMapper;

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
      TRoleMapper.Invalidate;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataTenantExecute(Sender: TObject);
begin
  var lDialog := TfmTenant.Create(Self);
  try
    var lCrudConfig: IEntryCrudConfig<TDtoTenant, TDtoTenant, UInt8, TVoid> := TCrudConfigTenantEntry.Create(fConnection);
    var lBusiness: ICrudCommands<UInt8, TVoid> := TCrudBusiness<TDtoTenant, TDtoTenant, UInt8, TVoid>.Create(lDialog, lCrudConfig);
    lBusiness.Initialize;
    lDialog.ShowModal;
    if lBusiness.DataChanged then
    begin
      TTenantReader.Instance.Invalidate;
      Caption := TVdmGlobals.GetVdmApplicationTitle + ': ' + TTenantReader.Instance.Tenant.Title;
    end;
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataUnitExecute(Sender: TObject);
begin
  acMasterdataUnit.Checked := not acMasterdataUnit.Checked;
  if acMasterdataUnit.Checked then
  begin
    ffraUnit.Show;
    ffraPerson.Hide;
    fBusinessUnit.LoadList;
  end
  else
  begin
    if fBusinessUnit.DataChanged then
      TUnitMapper.Invalidate;
    ffraPerson.Show;
    ffraUnit.Hide;
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

procedure TfmMain.acReportMemberUnitsExecute(Sender: TObject);
begin
  var lReport := TfmReportMemberUnits.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TfmMain.acReportPersonsExecute(Sender: TObject);
begin
  var lReport := TfmReportPersons.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TfmMain.acReportUnitMembersExecute(Sender: TObject);
begin
  var lReport := TfmReportUnitMembers.Create(fConnection);
  try
    lReport.Preview;
  finally
    lReport.Free;
  end;
end;

procedure TfmMain.acReportUnitRolesExecute(Sender: TObject);
begin
  var lReport := TfmReportUnitRoles.Create(fConnection);
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

  fCrudConfigUnit := TCrudConfigUnitAggregated.Create(fConnection, ffraUnit.MemberOfUI, fProgressIndicator);
  fBusinessUnit := TCrudBusiness<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>.Create(ffraUnit, fCrudConfigUnit);
  fBusinessUnit.Initialize;
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
    ':' + IntToStr(TConfigReader.Instance.Connection.Port) +
    ' / Database: ' + TConfigReader.Instance.Connection.Databasename;
  if Length(TConfigReader.Instance.Connection.SshRemoteHost) > 0 then
    lConnectionInfo := 'Remote Host: ' + TConfigReader.Instance.Connection.SshRemoteHost + ' / ' + lConnectionInfo;
  StatusBar.SimpleText := lConnectionInfo;

  fProgressForm := TfmProgressForm.Create(Self);
  fProgressIndicator := TProgressIndicator.Create(fProgressForm);

  ffraPerson := TfraPerson.Create(Self, fProgressIndicator);
  ffraPerson.Parent := Self;
  ffraPerson.Align := TAlign.alClient;
  ffraPerson.Show;

  ffraUnit := TfraUnit.Create(Self, acMasterdataUnit, fProgressIndicator);
  ffraUnit.Parent := Self;
  ffraUnit.Align := TAlign.alClient;
  ffraUnit.Hide;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fPersonBusinessIntf := nil;
  fConnection := nil;
  fProgressIndicator := nil;
  fProgressForm.Free;
end;

end.
