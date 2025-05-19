unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, System.Actions, Vcl.ActnList, Vcl.ExtCtrls,
  ProgressIndicatorIntf, unProgressForm, unPerson, unUnit, DtoUnit, DtoUnitAggregated, Vdm.Types,
  MainUI, MainBusinessIntf, ConfigReader, PersonAggregatedUI, CrudUI, MemberOfUI;

type
  TfmMain = class(TForm, IMainUI)
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
    acMasterdataPerson: TAction;
    acMasterdataPerson1: TMenuItem;
    acReportOneUnitMembers: TAction;
    acReportOneUnitMembers1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure acMasterdataUnitExecute(Sender: TObject);
    procedure acMasterdataRoleExecute(Sender: TObject);
    procedure acMasterdataAddressExecute(Sender: TObject);
    procedure acReportClubMembersExecute(Sender: TObject);
    procedure acReportUnitMembersExecute(Sender: TObject);
    procedure acMasterdataTenantExecute(Sender: TObject);
    procedure acReportUnitRolesExecute(Sender: TObject);
    procedure acReportMemberUnitsExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure acReportPersonsExecute(Sender: TObject);
    procedure acMasterdataPersonExecute(Sender: TObject);
    procedure acReportOneUnitMembersExecute(Sender: TObject);
    procedure acReportOneUnitMembersUpdate(Sender: TObject);
  strict private
    fBusiness: IMainBusiness;
    fProgressForm: TfmProgressForm;
    fProgressIndicator: IProgressIndicator;
    ffraPerson: TfraPerson;
    ffraUnit: TfraUnit;
    procedure SetBusiness(const aMainBusiness: IMainBusiness);
    procedure SetApplicationTitle(const aTitle: string);
    procedure SetConfiguration(const aConfig: TConfigConnection);
    function GetProgressIndicator: IProgressIndicator;
    function GetPersonAggregatedUI: IPersonAggregatedUI;
    function GetUnitCrudUI: ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TEntryFilter>;
    function GetUnitMemberOfsUI: IMemberOfUI;
    function GetCurrentUnitId: UInt32;
  end;

var
  fmMain: TfmMain;

implementation

uses System.UITypes, Vdm.Globals, unRole, unAddress, unTenant, ProgressIndicator,
  UnitMapper;

{$R *.dfm}

procedure TfmMain.acMasterdataAddressExecute(Sender: TObject);
begin
  var lDialog := TfmAddress.Create(Self);
  try
    fBusiness.OpenCrudAddress(lDialog,
      function: Integer
      begin
        Result := lDialog.ShowModal;
      end
    );
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataPersonExecute(Sender: TObject);
begin
  acMasterdataPerson.Enabled := False;
  acMasterdataUnit.Enabled := True;
  fBusiness.OpenCrudPerson;
end;

procedure TfmMain.acMasterdataRoleExecute(Sender: TObject);
begin
  var lDialog := TfmRole.Create(Self);
  try
    fBusiness.OpenCrudRole(lDialog,
      function: Integer
      begin
        Result := lDialog.ShowModal;
      end
    );
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataTenantExecute(Sender: TObject);
begin
  var lDialog := TfmTenant.Create(Self);
  try
    fBusiness.OpenCrudTenant(lDialog,
      function: Integer
      begin
        Result := lDialog.ShowModal;
      end
    );
  finally
    lDialog.Free;
  end;
end;

procedure TfmMain.acMasterdataUnitExecute(Sender: TObject);
begin
  acMasterdataUnit.Enabled := False;
  acMasterdataPerson.Enabled := True;
  fBusiness.OpenCrudUnit;
end;

procedure TfmMain.acReportClubMembersExecute(Sender: TObject);
begin
  fBusiness.OpenReportClubMembers;
end;

procedure TfmMain.acReportMemberUnitsExecute(Sender: TObject);
begin
  fBusiness.OpenReportMemberUnits;
end;

procedure TfmMain.acReportOneUnitMembersExecute(Sender: TObject);
begin
  fBusiness.OpenReportOneUnitMembers(GetCurrentUnitId);
end;

procedure TfmMain.acReportOneUnitMembersUpdate(Sender: TObject);
begin
  var lUnitId := GetCurrentUnitId;
  if lUnitId > 0 then
  begin
    acReportOneUnitMembers.Enabled := True;
    acReportOneUnitMembers.Caption := 'Personen für "' +
      TUnitMapper.Instance.Data.Data.GetAllEntries.GetStringById(lUnitId, '???') + '"';
  end
  else
  begin
    acReportOneUnitMembers.Enabled := False;
    acReportOneUnitMembers.Caption := 'Personen für ...';
  end;
end;

procedure TfmMain.acReportPersonsExecute(Sender: TObject);
begin
  fBusiness.OpenReportPersons;
end;

procedure TfmMain.acReportUnitMembersExecute(Sender: TObject);
begin
  fBusiness.OpenReportUnitMembers;
end;

procedure TfmMain.acReportUnitRolesExecute(Sender: TObject);
begin
  fBusiness.OpenReportUnitRoles;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  fProgressForm := TfmProgressForm.Create(Self);
  fProgressIndicator := TProgressIndicator.Create(fProgressForm);

  ffraPerson := TfraPerson.Create(Self, fProgressIndicator);
  ffraPerson.Parent := Self;
  ffraPerson.Align := TAlign.alClient;
  ffraPerson.Show;
  acMasterdataPerson.Enabled := False;

  ffraUnit := TfraUnit.Create(Self, fProgressIndicator);
  ffraUnit.Parent := Self;
  ffraUnit.Align := TAlign.alClient;
  ffraUnit.Hide;
  acMasterdataUnit.Enabled := True;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fProgressIndicator := nil;
  fProgressForm.Free;
end;

procedure TfmMain.FormShow(Sender: TObject);
begin
  fBusiness.UIIsReady;
end;

function TfmMain.GetCurrentUnitId: UInt32;
begin
  Result := 0;
  if ffraUnit.Visible then
    Result := ffraUnit.CurrentUnitId;
  if (Result = 0) or ffraPerson.Visible then
    Result := ffraPerson.CurrentUnitId;
end;

function TfmMain.GetPersonAggregatedUI: IPersonAggregatedUI;
begin
  Result := ffraPerson;
end;

function TfmMain.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

function TfmMain.GetUnitCrudUI: ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TEntryFilter>;
begin
  Result := ffraUnit;
end;

function TfmMain.GetUnitMemberOfsUI: IMemberOfUI;
begin
  Result := ffraUnit.MemberOfUI;
end;

procedure TfmMain.SetApplicationTitle(const aTitle: string);
begin
  Caption := aTitle;
end;

procedure TfmMain.SetBusiness(const aMainBusiness: IMainBusiness);
begin
  fBusiness := aMainBusiness;
end;

procedure TfmMain.SetConfiguration(const aConfig: TConfigConnection);
begin
  shaTestConnectionWarning.Visible := aConfig.ShapeVisible;
  if shaTestConnectionWarning.Visible then
  begin
    var lColor: TColor;
    if not TryStringToColor('$' + aConfig.ShapeColor, lColor) then
      lColor := TColorRec.SysHighlight;
    shaTestConnectionWarning.Brush.Color := lColor;
  end;
  var lConnectionInfo := 'Server: ' + aConfig.DatabaseHost + ':' + IntToStr(aConfig.DatabasePort) +
    ' / Database: ' + aConfig.DatabaseName;
  if Length(aConfig.SshServerHost) > 0 then
    lConnectionInfo := 'Ssh Server: ' + aConfig.SshServerHost + ' / ' + lConnectionInfo;
  StatusBar.SimpleText := lConnectionInfo;
end;

end.
