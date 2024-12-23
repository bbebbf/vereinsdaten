unit unMain;

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
    alPersonActionList: TActionList;
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
  strict private
    fActivated: Boolean;
    fCurrentRecordId: UInt32;
    fNewRecordStarted: Boolean;
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
    procedure PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem);

    procedure Initialize(const aCommands: ICrudCommands<UInt32>); overload;
    procedure Initialize(const aCommands: IMainBusinessIntf); overload;
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aRecord: TDtoPersonAggregated);
    procedure ListEnumEnd;
    procedure DeleteRecordfromUI(const aPersonId: UInt32);
    procedure ClearRecordUI;
    procedure StartNewRecord;
    procedure SetRecordToUI(const aRecord: TDtoPersonAggregated; const aRecordAsNewEntry: Boolean);
    function GetRecordFromUI(var aRecord: TDtoPersonAggregated): Boolean;
    procedure LoadAvailableAdresses;
    procedure LoadCurrentRecord(const aPersonId: UInt32);
  public
    { Public-Deklarationen }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

uses VdmGlobals, ConfigReader, StringTools, MessageDialogs;

{ TfmMain }

procedure TfmMain.acPersonReloadCurrentRecordExecute(Sender: TObject);
begin
  fMainBusinessIntf.ReloadCurrentRecord(fCurrentRecordId);
  SetEditMode(False);
end;

procedure TfmMain.acPersonSaveCurrentRecordExecute(Sender: TObject);
begin
  var lPersonId: UInt32 := 0;
  if not fNewRecordStarted then
    lPersonId := fCurrentRecordId;

  var lResponse := fMainBusinessIntf.SaveCurrentRecord(lPersonId);
  if lResponse.Status = TCrudSaveRecordStatus.Successful then
  begin
    SetEditMode(False);
  end
  else if lResponse.Status = TCrudSaveRecordStatus.CancelledWithMessage then
  begin
    TMessageDialogs.Ok(lResponse.MessageText, TMsgDlgType.mtInformation);
  end;
end;

procedure TfmMain.acPersonStartNewRecordExecute(Sender: TObject);
begin
  StartNewRecord;
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

procedure TfmMain.ClearRecordUI;
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
end;

procedure TfmMain.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmMain.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmMain.DeleteRecordfromUI(const aPersonId: UInt32);
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
        LoadCurrentRecord(aData.Value);
      end
      else
      begin
        ClearRecordUI;
      end;
    end,
    200
  );


  Caption := TVdmGlobals.GetVdmApplicationTitle;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fDelayedExecute.Free;
  fPersonListviewAttachedData.Free;
  fComponentValueChangedObserver.Free;
end;

function TfmMain.GetMemberOfUI: IPersonMemberOfUI;
begin
  Result := fPersonMemberOf;
end;

function TfmMain.GetRecordFromUI(var aRecord: TDtoPersonAggregated): Boolean;
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
  if cbPersonBirthdayKnown.Checked then
    aRecord.Birthday := dtPersonBirthday.Date
  else
    aRecord.Birthday := 0;
  aRecord.Active := cbPersonActive.Checked;
  aRecord.AddressIndex := cbPersonAddress.ItemIndex;

  aRecord.CreateNewAddress := cbCreateNewAddress.Checked;
  aRecord.NewAddressStreet := edNewAddressStreet.Text;
  aRecord.NewAddressPostalcode := edNewAddressPostalcode.Text;
  aRecord.NewAddressCity := edNewAddressCity.Text;

  aRecord.MembershipNoMembership := cbMembership.ItemIndex <= 0;
  aRecord.MembershipActive := cbMembership.ItemIndex = 1;
  aRecord.MembershipNumber := StrToIntDef(edMembershipNumber.Text, 0);
  if cbMembershipBeginKnown.Checked then
    aRecord.MembershipBeginDate := dtMembershipBegin.Date
  else
    aRecord.MembershipBeginDate := 0;
  if cbMembershipEndKnown.Checked then
  begin
    aRecord.MembershipEndDate := dtMembershipEnd.Date;
    aRecord.MembershipEndDateText := '';
  end
  else
  begin
    aRecord.MembershipEndDate := 0;
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

procedure TfmMain.LoadCurrentRecord(const aPersonId: UInt32);
begin
  fCurrentRecordId := aPersonId;
  fNewRecordStarted := False;
  fMainBusinessIntf.LoadCurrentRecord(aPersonId);
  if pcPersonDetails.ActivePage = tsMemberOf then
  begin
    fMainBusinessIntf.LoadPersonsMemberOfs(aPersonId);
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
  end
  else
  begin
    StartNewRecord;
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
    fMainBusinessIntf.LoadPersonsMemberOfs(fCurrentRecordId);
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

procedure TfmMain.PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem);
begin
  var lPersonItemData := default(TPersonListItemData);
  lPersonItemData.PersonActive := aPerson.Aktiv;
  var lItem := aItem;
  if Assigned(lItem) then
  begin
    fPersonListviewAttachedData.UpdateItem(aItem, aPerson.Id, lPersonItemData);
  end
  else
  begin
    lItem := fPersonListviewAttachedData.AddItem(aPerson.Id, lPersonItemData);
  end;
  lItem.Caption := aPerson.ToString;
end;

procedure TfmMain.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acPersonSaveCurrentRecord.Enabled := fInEditMode;
  acPersonReloadCurrentRecord.Enabled := fInEditMode;
  if not fInEditMode then
    fNewRecordStarted := False;
end;

procedure TfmMain.SetRecordToUI(const aRecord: TDtoPersonAggregated; const aRecordAsNewEntry: Boolean);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edPersonFirstname.Text := aRecord.Firstname;
  edPersonPraeposition.Text := aRecord.Praeposition;
  edPersonLastname.Text := aRecord.Lastname;
  fPersonBirthdayHandler.Datetime := aRecord.Birthday;

  if aRecordAsNewEntry then
  begin
    PersonEntryToListItem(aRecord.Person, nil)
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

procedure TfmMain.StartNewRecord;
begin
  fNewRecordStarted := True;
  ClearRecordUI;
  tsPersonaldata.Caption := '...';
  tsMemberOf.Caption := 'ist Mitglied von ...';
end;

end.
