unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoPerson, ListviewAttachedData, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  MainBusinessIntf, PersonAggregatedUI, DtoPersonAggregated;

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
    tsBasicdata: TTabSheet;
    edPersonFirstname: TEdit;
    lbPersonFirstname: TLabel;
    edPersonPraeposition: TEdit;
    lbPersonLastname: TLabel;
    edPersonLastname: TEdit;
    dtPersonBithday: TDateTimePicker;
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure cbPersonBirthdayKnownClick(Sender: TObject);
    procedure acPersonSaveCurrentRecordExecute(Sender: TObject);
    procedure acPersonReloadCurrentRecordExecute(Sender: TObject);
    procedure cbCreateNewAddressClick(Sender: TObject);
    procedure cbShowInactivePersonsClick(Sender: TObject);
  private
    { Private-Deklarationen }
  strict private
    fActivated: Boolean;
    fMainBusinessIntf: IMainBusinessIntf;
    fDatetimePickerFormat: string;
    fPersonListviewAttachedData: TListviewAttachedData<Int32, TPersonListItemData>;
    procedure PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem);

    procedure Initialize(const aCommands: ICrudCommands<Int32>); overload;
    procedure Initialize(const aCommands: IMainBusinessIntf); overload;
    procedure LoadUIList(const aList: TList<TDtoPersonAggregated>);
    procedure DeleteRecordfromUI(const aPersonId: Int32);
    procedure ClearRecordUI;
    procedure SetRecordToUI(const aRecord: TDtoPersonAggregated);
    function GetRecordFromUI(var aRecord: TDtoPersonAggregated): Boolean;
    procedure LoadAvailableAdresses;
    procedure LoadCurrentRecord(const aPersonId: Int32);
  public
    { Public-Deklarationen }
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{ TfmMain }

procedure TfmMain.acPersonReloadCurrentRecordExecute(Sender: TObject);
begin
  var lPersonId: Int32;
  if fPersonListviewAttachedData.TryGetKey(lvPersonListview.Selected, lPersonId) then
    fMainBusinessIntf.ReloadCurrentRecord(lPersonId);
end;

procedure TfmMain.acPersonSaveCurrentRecordExecute(Sender: TObject);
begin
  var lPersonId: Int32;
  if fPersonListviewAttachedData.TryGetKey(lvPersonListview.Selected, lPersonId) then
    fMainBusinessIntf.SaveCurrentRecord(lPersonId);
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

procedure TfmMain.cbPersonBirthdayKnownClick(Sender: TObject);
begin
  if cbPersonBirthdayKnown.Checked then
  begin
    dtPersonBithday.Enabled := True;
    dtPersonBithday.Format := fDatetimePickerFormat;
  end
  else
  begin
    dtPersonBithday.Enabled := False;
    dtPersonBithday.Format := ' ';
  end;
end;

procedure TfmMain.cbShowInactivePersonsClick(Sender: TObject);
begin
  fMainBusinessIntf.ShowInactivePersons := cbShowInactivePersons.Checked;
end;

procedure TfmMain.ClearRecordUI;
begin
  edPersonFirstname.Text := '';
  edPersonPraeposition.Text := '';
  edPersonLastname.Text := '';
  cbPersonBirthdayKnown.Checked := False;
  cbPersonBirthdayKnownClick(cbPersonBirthdayKnown);
  dtPersonBithday.Date := Now;
  cbPersonActive.Checked := True;
  cbPersonAddress.ItemIndex := -1;
  cbCreateNewAddress.Checked := False;
  edNewAddressStreet.Text := '';
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  cbCreateNewAddressClick(cbCreateNewAddress);
end;

procedure TfmMain.DeleteRecordfromUI(const aPersonId: Int32);
begin

end;

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;
  fMainBusinessIntf.LoadList;
  LoadAvailableAdresses;
  ClearRecordUI;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  fPersonListviewAttachedData := TListviewAttachedData<Int32, TPersonListItemData>.Create(lvPersonListview);
  fDatetimePickerFormat := dtPersonBithday.Format;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fPersonListviewAttachedData.Free;
end;

function TfmMain.GetRecordFromUI(var aRecord: TDtoPersonAggregated): Boolean;
begin
  Result := True;
  aRecord.Firstname := edPersonFirstname.Text;
  aRecord.Praeposition := edPersonPraeposition.Text;
  aRecord.Lastname := edPersonLastname.Text;
  if cbPersonBirthdayKnown.Checked then
    aRecord.Birthday := dtPersonBithday.Date
  else
    aRecord.Birthday := 0;
  aRecord.Active := cbPersonActive.Checked;
  aRecord.AddressIndex := cbPersonAddress.ItemIndex;

  aRecord.CreateNewAddress := cbCreateNewAddress.Checked;
  aRecord.NewAddressStreet := edNewAddressStreet.Text;
  aRecord.NewAddressPostalcode := edNewAddressPostalcode.Text;
  aRecord.NewAddressCity := edNewAddressCity.Text;
end;

procedure TfmMain.Initialize(const aCommands: IMainBusinessIntf);
begin
  fMainBusinessIntf := aCommands;
end;

procedure TfmMain.Initialize(const aCommands: ICrudCommands<Int32>);
begin

end;

procedure TfmMain.LoadAvailableAdresses;
begin
  fMainBusinessIntf.LoadAvailableAddresses(cbPersonAddress.Items);
end;

procedure TfmMain.LoadCurrentRecord(const aPersonId: Int32);
begin
  fMainBusinessIntf.LoadCurrentRecord(aPersonId);
end;

procedure TfmMain.LoadUIList(const aList: TList<TDtoPersonAggregated>);
begin
  lvPersonListview.Items.BeginUpdate;
  try
    fPersonListviewAttachedData.Clear;
    lvPersonListview.Items.Clear;
    for var lEntry in aList do
    begin
      PersonEntryToListItem(lEntry.Person, nil);
    end;
  finally
    lvPersonListview.Items.EndUpdate;
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
  var lPersonId: Int32 := 0;
  if Selected then
  begin
    lPersonFound := fPersonListviewAttachedData.TryGetKey(Item, lPersonId);
  end;

  if lPersonFound then
  begin
    LoadCurrentRecord(lPersonId);
  end
  else
  begin
    ClearRecordUI;
  end;
end;

procedure TfmMain.PersonEntryToListItem(const aPerson: TDtoPerson; const aItem: TListItem);
begin
  var lPersonItemData := default(TPersonListItemData);
  lPersonItemData.PersonActive := aPerson.Aktiv;
  if Assigned(aItem) then
  begin
    fPersonListviewAttachedData.UpdateItem(aItem, aPerson.Id, lPersonItemData);
    aItem.Caption := aPerson.ToString;
  end
  else
  begin
    var lItem := fPersonListviewAttachedData.AddItem(aPerson.Id, lPersonItemData);
    lItem.Caption := aPerson.ToString;
  end;
end;

procedure TfmMain.SetRecordToUI(const aRecord: TDtoPersonAggregated);
begin
  edPersonFirstname.Text := aRecord.Firstname;
  edPersonPraeposition.Text := aRecord.Praeposition;
  edPersonLastname.Text := aRecord.Lastname;
  cbPersonBirthdayKnown.Checked := (aRecord.Birthday > 0);
  cbPersonBirthdayKnownClick(cbPersonBirthdayKnown);
  if aRecord.Birthday > 0 then
    dtPersonBithday.Date := aRecord.Birthday
  else
    dtPersonBithday.Date := Now;
  PersonEntryToListItem(aRecord.Person, lvPersonListview.Selected);
  cbPersonActive.Checked := aRecord.Active;
  cbPersonAddress.ItemIndex := aRecord.AddressIndex;
  cbCreateNewAddress.Checked := False;
  edNewAddressStreet.Text := '';
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  cbCreateNewAddressClick(cbCreateNewAddress);
end;

end.
