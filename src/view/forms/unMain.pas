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
    acReportBirthdays: TAction;
    Geburtstagsliste1: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
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
    procedure acReportBirthdaysExecute(Sender: TObject);
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
    procedure UpdateMainActions;
  end;

var
  fmMain: TfmMain;

implementation

uses System.UITypes, Vdm.Globals, unRole, unAddress, unTenant, ProgressIndicator,
  UnitMapper,

  unExporter.Params.ZeroParams,
  Exporter.Members.Types, unExporter.Params.UnitMember,
  Exporter.Persons.Types, unExporter.Params.Persons,
  unExporter.Params.Birthdays, unExporter.Params.MemberUnit;

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
  fBusiness.OpenCrudUnit;
end;

procedure TfmMain.acReportBirthdaysExecute(Sender: TObject);
begin
  var lParamsProvider := TfmExporterParamsBirthdays.Create(Self);
  try
    fBusiness.OpenReportBirthdays(lParamsProvider);
  finally
    lParamsProvider.Free;
  end;
end;

procedure TfmMain.acReportClubMembersExecute(Sender: TObject);
begin
  var lParamsProvider := TfmExporterParamsZeroParams.Create(Self, 'Vereinsmitglieder exportieren');
  try
    fBusiness.OpenReportClubMembers(lParamsProvider);
  finally
    lParamsProvider.Free;
  end;
end;

procedure TfmMain.acReportMemberUnitsExecute(Sender: TObject);
begin
  var lParams: TExporterMembersParams := nil;
  var lParamsProvider: TfmExporterParamsMemberUnit := nil;
  try
    lParams := TExporterMembersParams.Create;
    lParams.Persons.IncludeInactive := ffraPerson.cbShowInactivePersons.Checked;
    lParams.Persons.IncludeExternal := ffraPerson.cbShowExternalPersons.Checked;

    lParamsProvider := TfmExporterParamsMemberUnit.Create(Self, 'Personen und Einheiten exportieren');
    fBusiness.OpenReportMemberUnits(lParams, lParamsProvider);
  finally
    lParamsProvider.Free;
    lParams.Free;
  end;
end;

procedure TfmMain.acReportPersonsExecute(Sender: TObject);
begin
  var lParams: TExporterPersonsParams := nil;
  var lParamsProvider: TfmExporterParamsPersons := nil;
  try
    lParams := TExporterPersonsParams.Create;
    lParams.IncludeInactive := ffraPerson.cbShowInactivePersons.Checked;
    lParams.IncludeExternal := ffraPerson.cbShowExternalPersons.Checked;

    lParamsProvider := TfmExporterParamsPersons.Create(Self, 'Personen exportieren');
    fBusiness.OpenReportPersons(lParams, lParamsProvider);
  finally
    lParamsProvider.Free;
    lParams.Free;
  end;
end;

procedure TfmMain.acReportUnitMembersExecute(Sender: TObject);
begin
  var lUnitIds: TArray<UInt32> := [];
  if ffraUnit.Visible then
    lUnitIds := ffraUnit.CheckedUnitIds;

  var lParams: TExporterMembersParams := nil;
  var lParamsProvider: TfmExporterParamsUnitMember := nil;
  try
    lParams := TExporterMembersParams.Create;
    lParams.Units.CheckedUnitIds.AddRange(lUnitIds);

    lParamsProvider := TfmExporterParamsUnitMember.Create(Self);
    fBusiness.OpenReportUnitMembers(lParams, lParamsProvider);
  finally
    lParamsProvider.Free;
    lParams.Free;
  end;
end;

procedure TfmMain.acReportUnitRolesExecute(Sender: TObject);
begin
  var lUnitIds: TArray<UInt32> := [];
  if ffraUnit.Visible then
    lUnitIds := ffraUnit.CheckedUnitIds;

  var lParams: TExporterMembersParams := nil;
  var lParamsProvider: TfmExporterParamsUnitMember := nil;
  try
    lParams := TExporterMembersParams.Create;
    lParams.Units.CheckedUnitIds.AddRange(lUnitIds);

    lParamsProvider := TfmExporterParamsUnitMember.Create(Self, 'Rollen und Einheiten exportieren');
    fBusiness.OpenReportUnitRoles(lParams, lParamsProvider);
  finally
    lParamsProvider.Free;
    lParams.Free;
  end;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  fProgressForm := TfmProgressForm.Create(Self);
  fProgressIndicator := TProgressIndicator.Create(fProgressForm);

  ffraPerson := TfraPerson.Create(Self, fProgressIndicator);
  ffraPerson.Parent := Self;
  ffraPerson.Align := TAlign.alClient;
  ffraPerson.Hide;

  ffraUnit := TfraUnit.Create(Self, fProgressIndicator);
  ffraUnit.Parent := Self;
  ffraUnit.Align := TAlign.alClient;
  ffraUnit.Hide;
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

procedure TfmMain.UpdateMainActions;
begin
  acMasterdataPerson.Enabled := not fBusiness.IsCrudPersonActivated;
  acMasterdataUnit.Enabled := not fBusiness.IsCrudUnitActivated;
end;

end.
