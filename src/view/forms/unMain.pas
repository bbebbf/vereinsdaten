﻿unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoPerson, ListviewAttachedData, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  MainBusinessIntf, PersonAggregatedUI, DtoPersonAggregated, ComponentValueChangedObserver,
  unPersonMemberOf, PersonMemberOfUI, DelayedExecute, CheckboxDatetimePickerHandler;

type
  TPersonListItemData = record
    PersonActive: Boolean;
  end;

  TfmMain = class(TForm, IPersonAggregatedUI)
    StatusBar: TStatusBar;
    pnPersonListview: TPanel;
    Splitter1: TSplitter;
    pnPersonDetails: TPanel;
    MainMenu: TMainMenu;
    Datei1: TMenuItem;
    lvPersonListview: TListView;
    pcPersonDetails: TPageControl;
    tsPersonaldata: TTabSheet;
    edPersonFirstname: TEdit;
    lbPersonFirstname: TLabel;
    edPersonPraeposition: TEdit;
    lbPersonLastname: TLabel;
    edPersonLastname: TEdit;
    dtPersonBirthday: TDateTimePicker;
    lbPersonBirthday: TLabel;
    cbPersonBirthdayKnown: TCheckBox;
    alActionList: TActionList;
    acPersonSaveCurrentRecord: TAction;
    acPersonReloadCurrentRecord: TAction;
    btPersonSave: TButton;
    btPersonReload: TButton;
    cbPersonActive: TCheckBox;
    cbPersonAddress: TComboBox;
    lbPersonAdress: TLabel;
    cbCreateNewAddress: TCheckBox;
    edNewAddressStreet: TEdit;
    lbNewAddressPostalcode: TLabel;
    edNewAddressPostalcode: TEdit;
    lbNewAddressCity: TLabel;
    edNewAddressCity: TEdit;
    pnFilter: TPanel;
    cbShowInactivePersons: TCheckBox;
    cbMembership: TComboBox;
    lbMembership: TLabel;
    edMembershipNumber: TEdit;
    lbMembershipnumber: TLabel;
    cbMembershipBeginKnown: TCheckBox;
    dtMembershipBegin: TDateTimePicker;
    lbMembershipBegin: TLabel;
    lbMembershipEnd: TLabel;
    cbMembershipEndKnown: TCheckBox;
    dtMembershipEnd: TDateTimePicker;
    edMembershipEndText: TEdit;
    lbMembershipEndReason: TLabel;
    edMembershipEndReason: TEdit;
    lbMembershipEndText: TLabel;
    acPersonStartNewRecord: TAction;
    btPersonStartNewRecord: TButton;
    tsMemberOf: TTabSheet;
    Stammdaten1: TMenuItem;
    Einheiten1: TMenuItem;
    Rollen1: TMenuItem;
    Adressen1: TMenuItem;
    acMasterdataUnits: TAction;
    acMasterdataAddresses: TAction;
    acMasterdataRoles: TAction;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acPersonSaveCurrentRecordExecute(Sender: TObject);
    procedure acPersonReloadCurrentRecordExecute(Sender: TObject);
    procedure cbCreateNewAddressClick(Sender: TObject);
    procedure cbShowInactivePersonsClick(Sender: TObject);
    procedure cbMembershipEndKnownClick(Sender: TObject);
    procedure acPersonStartNewRecordExecute(Sender: TObject);
    procedure pcPersonDetailsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure pcPersonDetailsChange(Sender: TObject);
    procedure acMasterdataUnitsExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fMainBusinessIntf: IMainBusinessIntf;
    fPersonListviewAttachedData: TListviewAttachedData<UInt32, TPersonListItemData>;
    fPersonMemberOf: TfraPersonMemberOf;
    fDelayedExecute: TDelayedExecute<TPair<Boolean, UInt32>>;
    fPersonBirthdayHandler: TCheckboxDatetimePickerHandler;
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;

    function GetMemberOfUI: IPersonMemberOfUI;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    function PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem): TListItem;

    procedure Initialize(const aCommands: ICrudCommands<UInt32>); overload;
    procedure Initialize(const aCommands: IMainBusinessIntf); overload;
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aRecord: TDtoPersonAggregated);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aPersonId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aRecord: TDtoPersonAggregated; const aAsNewEntry: Boolean);
    function GetEntryFromUI(var aRecord: TDtoPersonAggregated): Boolean;
    procedure LoadAvailableAdresses;
    procedure LoadCurrentEntry(const aPersonId: UInt32);
  public
    { Public-Deklarationen }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses VdmGlobals, ConfigReader, StringTools, MessageDialogs, unUnit;

{ TfmMain }

procedure TfmMain.acMasterdataUnitsExecute(Sender: TObject);
begin
  var lDialogUnit := TfmUnit.Create(Self);
  try
    fMainBusinessIntf.CallDialogUnits(lDialogUnit);
    lDialogUnit.ShowModal;
  finally
    lDialogUnit.Free;
  end;
end;

procedure TfmMain.acPersonReloadCurrentRecordExecute(Sender: TObject);
begin
  fMainBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfmMain.acPersonSaveCurrentRecordExecute(Sender: TObject);
begin
  var lResponse := fMainBusinessIntf.SaveCurrentEntry;
  if lResponse.Status = TCrudSaveStatus.Successful then
  begin
    SetEditMode(False);
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledWithMessage then
  begin
    TMessageDialogs.Ok(lResponse.MessageText, TMsgDlgType.mtInformation);
  end;
end;

procedure TfmMain.acPersonStartNewRecordExecute(Sender: TObject);
begin
  fMainBusinessIntf.StartNewEntry;
  pcPersonDetails.ActivePage := tsPersonaldata;
  edPersonFirstname.SetFocus;
end;

procedure TfmMain.cbCreateNewAddressClick(Sender: TObject);
begin
  cbPersonAddress.Enabled := not cbCreateNewAddress.Checked;
  edNewAddressStreet.Enabled := cbCreateNewAddress.Checked;
  edNewAddressPostalcode.Enabled := cbCreateNewAddress.Checked;
  edNewAddressCity.Enabled := cbCreateNewAddress.Checked;
  lbNewAddressPostalcode.Enabled := cbCreateNewAddress.Checked;
  lbNewAddressCity.Enabled := cbCreateNewAddress.Checked;
end;

procedure TfmMain.cbMembershipEndKnownClick(Sender: TObject);
begin
  lbMembershipEndText.Enabled := not dtMembershipEnd.Enabled;
  edMembershipEndText.Enabled := not dtMembershipEnd.Enabled;
end;

procedure TfmMain.cbShowInactivePersonsClick(Sender: TObject);
begin
  fMainBusinessIntf.ShowInactivePersons := cbShowInactivePersons.Checked;
end;

procedure TfmMain.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edPersonFirstname.Text := '';
  edPersonPraeposition.Text := '';
  edPersonLastname.Text := '';
  fPersonBirthdayHandler.Clear;

  cbPersonActive.Checked := True;
  cbPersonAddress.ItemIndex := -1;
  cbCreateNewAddress.Checked := False;
  edNewAddressStreet.Text := '';
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  cbCreateNewAddressClick(cbCreateNewAddress);

  cbMembership.ItemIndex := 0;
  edMembershipNumber.Text := '';

  fActiveSinceHandler.Clear;
  fActiveUntilHandler.Clear;
  edMembershipEndText.Text := '';

  fComponentValueChangedObserver.EndUpdate;
  tsPersonaldata.Caption := '...';
  tsMemberOf.Caption := 'ist Mitglied von ...';
end;

procedure TfmMain.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmMain.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmMain.DeleteEntryFromUI(const aPersonId: UInt32);
begin

end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;

  var lConnectionInfo := 'Server: ' + TConfigReader.Instance.Connection.Host +
    ':' + IntToStr(TConfigReader.Instance.Connection.Port);
  if Length(TConfigReader.Instance.Connection.SshRemoteHost) > 0 then
    lConnectionInfo := 'Remote Host: ' + TConfigReader.Instance.Connection.SshRemoteHost + ' / ' + lConnectionInfo;
  StatusBar.SimpleText := lConnectionInfo;

  SetEditMode(False);
  LoadAvailableAdresses;
  fMainBusinessIntf.LoadList;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  fPersonMemberOf := TfraPersonMemberOf.Create(Self);
  fPersonMemberOf.Parent := tsMemberOf;
  fPersonMemberOf.Align := TAlign.alClient;

  fPersonBirthdayHandler := TCheckboxDatetimePickerHandler.Create(cbPersonBirthdayKnown, dtPersonBirthday);
  fActiveSinceHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipBeginKnown, dtMembershipBegin);
  fActiveUntilHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipEndKnown, dtMembershipEnd);

  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edPersonFirstname);
  fComponentValueChangedObserver.RegisterEdit(edPersonPraeposition);
  fComponentValueChangedObserver.RegisterEdit(edPersonLastname);
  fComponentValueChangedObserver.RegisterCheckbox(cbPersonBirthdayKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtPersonBirthday);
  fComponentValueChangedObserver.RegisterCheckbox(cbPersonActive);
  fComponentValueChangedObserver.RegisterCombobox(cbPersonAddress);
  fComponentValueChangedObserver.RegisterCheckbox(cbCreateNewAddress);
  fComponentValueChangedObserver.RegisterEdit(edNewAddressStreet);
  fComponentValueChangedObserver.RegisterEdit(edNewAddressPostalcode);
  fComponentValueChangedObserver.RegisterEdit(edNewAddressCity);
  fComponentValueChangedObserver.RegisterCombobox(cbMembership);
  fComponentValueChangedObserver.RegisterEdit(edMembershipNumber);
  fComponentValueChangedObserver.RegisterCheckbox(cbMembershipBeginKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtMembershipBegin);
  fComponentValueChangedObserver.RegisterCheckbox(cbMembershipEndKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtMembershipEnd);
  fComponentValueChangedObserver.RegisterEdit(edMembershipEndText);
  fComponentValueChangedObserver.RegisterEdit(edMembershipEndReason);

  fPersonListviewAttachedData := TListviewAttachedData<UInt32, TPersonListItemData>.Create(lvPersonListview);
  fDelayedExecute := TDelayedExecute<TPair<Boolean, UInt32>>.Create(
    procedure(const aData: TPair<Boolean, UInt32>)
    begin
      if aData.Key then
      begin
        LoadCurrentEntry(aData.Value);
      end
      else
      begin
        ClearEntryFromUI;
      end;
    end,
    200
  );


  Caption := TVdmGlobals.GetVdmApplicationTitle;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fPersonBirthdayHandler.Free;
  fActiveSinceHandler.Free;
  fActiveUntilHandler.Free;
  fDelayedExecute.Free;
  fPersonListviewAttachedData.Free;
  fComponentValueChangedObserver.Free;
end;

function TfmMain.GetMemberOfUI: IPersonMemberOfUI;
begin
  Result := fPersonMemberOf;
end;

function TfmMain.GetEntryFromUI(var aRecord: TDtoPersonAggregated): Boolean;
begin
  if TStringTools.IsEmpty(edPersonFirstname.Text) and TStringTools.IsEmpty(edPersonLastname.Text) then
  begin
    edPersonFirstname.SetFocus;
    TMessageDialogs.Ok('Vorname oder Nachname müssen angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;
  if (cbMembership.ItemIndex > 0) and TStringTools.IsEmpty(edMembershipNumber.Text) then
  begin
    edMembershipNumber.SetFocus;
    TMessageDialogs.Ok('Die Mitgliedsnummer muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;


  Result := True;
  aRecord.Firstname := edPersonFirstname.Text;
  aRecord.Praeposition := edPersonPraeposition.Text;
  aRecord.Lastname := edPersonLastname.Text;
  aRecord.Birthday := fPersonBirthdayHandler.Datetime;
  aRecord.Active := cbPersonActive.Checked;
  aRecord.AddressIndex := cbPersonAddress.ItemIndex;

  aRecord.CreateNewAddress := cbCreateNewAddress.Checked;
  aRecord.NewAddressStreet := edNewAddressStreet.Text;
  aRecord.NewAddressPostalcode := edNewAddressPostalcode.Text;
  aRecord.NewAddressCity := edNewAddressCity.Text;

  aRecord.MembershipNoMembership := cbMembership.ItemIndex <= 0;
  aRecord.MembershipActive := cbMembership.ItemIndex = 1;
  aRecord.MembershipNumber := StrToIntDef(edMembershipNumber.Text, 0);
  aRecord.MembershipBeginDate := fActiveSinceHandler.Datetime;
  aRecord.MembershipEndDate := fActiveUntilHandler.Datetime;
  if cbMembershipEndKnown.Checked then
  begin
    aRecord.MembershipEndDateText := '';
  end
  else
  begin
    aRecord.MembershipEndDateText := edMembershipEndText.Text;
  end;
  aRecord.MembershipEndReason := edMembershipEndReason.Text;
end;

procedure TfmMain.Initialize(const aCommands: ICrudCommands<UInt32>);
begin

end;

procedure TfmMain.Initialize(const aCommands: IMainBusinessIntf);
begin
  fMainBusinessIntf := aCommands;
end;

procedure TfmMain.LoadAvailableAdresses;
begin
  fMainBusinessIntf.LoadAvailableAddresses(cbPersonAddress.Items);
end;

procedure TfmMain.LoadCurrentEntry(const aPersonId: UInt32);
begin
  fMainBusinessIntf.LoadCurrentEntry(aPersonId);
  if pcPersonDetails.ActivePage = tsMemberOf then
  begin
    fMainBusinessIntf.LoadPersonsMemberOfs;
  end;
  SetEditMode(False);
end;

procedure TfmMain.ListEnumBegin;
begin
  lvPersonListview.Items.BeginUpdate;
  fPersonListviewAttachedData.Clear;
end;

procedure TfmMain.ListEnumProcessItem(const aRecord: TDtoPersonAggregated);
begin
  PersonEntryToListItem(aRecord.Person, nil);
end;

procedure TfmMain.ListEnumEnd;
begin
  lvPersonListview.Items.EndUpdate;
  if lvPersonListview.Items.Count > 0 then
  begin
    lvPersonListview.Items[0].Selected := True;
  end;
end;

procedure TfmMain.lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lPersonListItemData: TPersonListItemData;
  if fPersonListviewAttachedData.TryGetExtraData(Item, lPersonListItemData) then
  begin
    if not lPersonListItemData.PersonActive then
      Sender.Canvas.Font.Color := clLtGray;
  end;
end;

procedure TfmMain.lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  var lPersonFound := False;
  var lPersonId: UInt32 := 0;
  if Selected then
  begin
    lPersonFound := fPersonListviewAttachedData.TryGetKey(Item, lPersonId);
  end;

  fDelayedExecute.SetData(TPair<Boolean, UInt32>.Create(lPersonFound, lPersonId));
end;

procedure TfmMain.pcPersonDetailsChange(Sender: TObject);
begin
  if pcPersonDetails.ActivePage = tsMemberOf then
  begin
    fMainBusinessIntf.LoadPersonsMemberOfs;
  end;
end;

procedure TfmMain.pcPersonDetailsChanging(Sender: TObject; var AllowChange: Boolean);
begin
  if pcPersonDetails.ActivePage = tsPersonaldata then
  begin
    if fInEditMode then
    begin
      AllowChange := False;
      TMessageDialogs.Ok('Die geänderten Daten müssen müssen vorher gespeichert oder verworfen werden.', TMsgDlgType.mtInformation);
    end;
  end;
end;

function TfmMain.PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem): TListItem;
begin
  var lPersonItemData := default(TPersonListItemData);
  lPersonItemData.PersonActive := aPerson.Aktiv;
  Result := aItem;
  if Assigned(Result) then
  begin
    fPersonListviewAttachedData.UpdateItem(aItem, aPerson.Id, lPersonItemData);
  end
  else
  begin
    Result := fPersonListviewAttachedData.AddItem(aPerson.Id, lPersonItemData);
  end;
  Result.Caption := aPerson.ToString;
end;

procedure TfmMain.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acPersonSaveCurrentRecord.Enabled := fInEditMode;
  acPersonReloadCurrentRecord.Enabled := fInEditMode;
end;

procedure TfmMain.SetEntryToUI(const aRecord: TDtoPersonAggregated; const aAsNewEntry: Boolean);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edPersonFirstname.Text := aRecord.Firstname;
  edPersonPraeposition.Text := aRecord.Praeposition;
  edPersonLastname.Text := aRecord.Lastname;
  fPersonBirthdayHandler.Datetime := aRecord.Birthday;

  if aAsNewEntry then
  begin
    var lNewItem := PersonEntryToListItem(aRecord.Person, nil);
    lNewItem.Selected := True;
    lNewItem.MakeVisible(False);
  end
  else
  begin
    PersonEntryToListItem(aRecord.Person, lvPersonListview.Selected);
  end;
  cbPersonActive.Checked := aRecord.Active;
  cbPersonAddress.ItemIndex := aRecord.AddressIndex;
  cbCreateNewAddress.Checked := False;
  edNewAddressStreet.Text := '';
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  cbCreateNewAddressClick(cbCreateNewAddress);

  if aRecord.MembershipId > 0 then
  begin
    if aRecord.MembershipActive then
      cbMembership.ItemIndex := 1
    else
      cbMembership.ItemIndex := 2;
    if aRecord.MembershipNumber > 0 then
      edMembershipNumber.Text := IntToStr(aRecord.MembershipNumber)
    else
      edMembershipNumber.Text := '';

    fActiveSinceHandler.Datetime := aRecord.MembershipBeginDate;
    fActiveUntilHandler.Datetime := aRecord.MembershipEndDate;

    edMembershipEndText.Text := aRecord.MembershipEndDateText;
    edMembershipEndReason.Text := aRecord.MembershipEndReason;
  end
  else
  begin
    cbMembership.ItemIndex := 0;
    edMembershipNumber.Text := '';
    fActiveSinceHandler.Clear;
    fActiveUntilHandler.Clear;
    edMembershipEndText.Text := '';
    edMembershipEndReason.Text := '';
  end;

  fComponentValueChangedObserver.EndUpdate;
  tsPersonaldata.Caption := aRecord.Person.ToString;
  tsMemberOf.Caption := 'ist Mitglied von ...';
end;

end.
