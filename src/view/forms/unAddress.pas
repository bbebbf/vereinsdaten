unit unAddress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoAddress, DtoAddressAggregated, ListviewAttachedData, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, DelayedExecute, Vdm.Types;

type
  TAddressListItemData = record
  end;

  TMemberOfListItemData = record
    MemberActive: Boolean;
  end;

  TfmAddress = class(TForm, ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>)
    pnListview: TPanel;
    Splitter1: TSplitter;
    pnDetails: TPanel;
    lvListview: TListView;
    alActionList: TActionList;
    acSaveCurrentEntry: TAction;
    acReloadCurrentEntry: TAction;
    pnFilter: TPanel;
    btSave: TButton;
    btReload: TButton;
    lvMemberOf: TListView;
    edAddressStreet: TEdit;
    lbAddressPostalcode: TLabel;
    edAddressPostalcode: TEdit;
    lbAddressCity: TLabel;
    edAddressCity: TEdit;
    lbAddressStreet: TLabel;
    acDeleteCurrentEntry: TAction;
    lbListviewItemCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TVoid>;
    fListviewAttachedData: TListviewAttachedData<UInt32, TAddressListItemData>;
    fMemberOfListviewAttachedData: TListviewAttachedData<UInt32, TMemberOfListItemData>;
    fDelayedExecute: TDelayedExecute<TPair<Boolean, UInt32>>;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    function EntryToListItem(const aEntry: TDtoAddress; const aItem: TListItem): TListItem;

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoAddress);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoAddressAggregated; const aAsNewEntry: Boolean);
    function GetEntryFromUI(var aEntry: TDtoAddressAggregated): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses StringTools, MessageDialogs, Vdm.Globals;

{ TfmAddress }

procedure TfmAddress.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfmAddress.acSaveCurrentEntryExecute(Sender: TObject);
begin
  var lResponse := fBusinessIntf.SaveCurrentEntry;
  if lResponse.Status = TCrudSaveStatus.Successful then
  begin
    SetEditMode(False);
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledWithMessage then
  begin
    TMessageDialogs.Ok(lResponse.MessageText, TMsgDlgType.mtInformation);
  end;
end;

procedure TfmAddress.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  SetEditMode(False);
end;

procedure TfmAddress.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edAddressStreet.Text := '';
  edAddressPostalcode.Text := '';
  edAddressCity.Text := '';
  fComponentValueChangedObserver.EndUpdate;
  lvMemberOf.Items.Clear;
end;

procedure TfmAddress.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmAddress.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmAddress.DeleteEntryFromUI(const aUnitId: UInt32);
begin

end;

procedure TfmAddress.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;

  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

procedure TfmAddress.FormCreate(Sender: TObject);
begin
  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edAddressStreet);
  fComponentValueChangedObserver.RegisterEdit(edAddressPostalcode);
  fComponentValueChangedObserver.RegisterEdit(edAddressCity);

  fListviewAttachedData := TListviewAttachedData<UInt32, TAddressListItemData>.Create(lvListview);
  fMemberOfListviewAttachedData := TListviewAttachedData<UInt32, TMemberOfListItemData>.Create(lvMemberOf);

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
end;

procedure TfmAddress.FormDestroy(Sender: TObject);
begin
  fDelayedExecute.Free;
  fMemberOfListviewAttachedData.Free;
  fListviewAttachedData.Free;
  fComponentValueChangedObserver.Free;
end;

function TfmAddress.GetEntryFromUI(var aEntry: TDtoAddressAggregated): Boolean;
begin
  if TStringTools.IsEmpty(edAddressCity.Text) then
  begin
    edAddressCity.SetFocus;
    TMessageDialogs.Ok('Der Ortsname muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Street := edAddressStreet.Text;
  aEntry.Postalcode := edAddressPostalcode.Text;
  aEntry.City := edAddressCity.Text;
end;

procedure TfmAddress.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
begin
  fBusinessIntf := aCommands;
end;

procedure TfmAddress.LoadCurrentEntry(const aEntryId: UInt32);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  SetEditMode(False);
end;

procedure TfmAddress.ListEnumBegin;
begin
  lvListview.Items.BeginUpdate;
  fListviewAttachedData.Clear;
end;

procedure TfmAddress.ListEnumProcessItem(const aEntry: TDtoAddress);
begin
  EntryToListItem(aEntry, nil);
end;

procedure TfmAddress.ListEnumEnd;
begin
  lvListview.Items.EndUpdate;
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
  lvListview.Items.EndUpdate;
  lbListviewItemCount.Caption := IntToStr(lvListview.Items.Count) + ' Datensätze';
  lvListview.SetFocus;
end;

procedure TfmAddress.lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lListItemData: TAddressListItemData;
  if fListviewAttachedData.TryGetExtraData(Item, lListItemData) then
  begin
  end;
end;

procedure TfmAddress.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  var lEntryFound := False;
  var lEntryId: UInt32 := 0;
  if Selected then
  begin
    lEntryFound := fListviewAttachedData.TryGetKey(Item, lEntryId);
  end;

  fDelayedExecute.SetData(TPair<Boolean, UInt32>.Create(lEntryFound, lEntryId));
end;

procedure TfmAddress.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lListItemData: TMemberOfListItemData;
  if fMemberOfListviewAttachedData.TryGetExtraData(Item, lListItemData) then
  begin
    if not lListItemData.MemberActive then
      Sender.Canvas.Font.Color := clLtGray;
  end;
end;

function TfmAddress.EntryToListItem(const aEntry: TDtoAddress; const aItem: TListItem): TListItem;
begin
  var lItemData := default(TAddressListItemData);
//  lItemData.UnitActive := aEntry.Active;
  Result := aItem;
  if Assigned(Result) then
  begin
    fListviewAttachedData.UpdateItem(aItem, aEntry.Id, lItemData);
  end
  else
  begin
    Result := fListviewAttachedData.AddItem(aEntry.Id, lItemData);
    Result.SubItems.Add('');
    Result.SubItems.Add('');
  end;
  Result.Caption := aEntry.City;
  Result.SubItems[0] := aEntry.Street;
  Result.SubItems[1] := aEntry.Postalcode;
end;

procedure TfmAddress.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
  acDeleteCurrentEntry.Enabled := not fInEditMode;
end;

procedure TfmAddress.SetEntryToUI(const aEntry: TDtoAddressAggregated; const aAsNewEntry: Boolean);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edAddressStreet.Text := aEntry.Street;
  edAddressPostalcode.Text := aEntry.Postalcode;
  edAddressCity.Text := aEntry.City;

  if aAsNewEntry then
  begin
    var lNewItem := EntryToListItem(aEntry.Address, nil);
    lNewItem.Selected := True;
    lNewItem.MakeVisible(False);
  end
  else
  begin
    EntryToListItem(aEntry.Address, lvListview.Selected);
  end;

  fComponentValueChangedObserver.EndUpdate;

  lvMemberOf.Items.BeginUpdate;
  try
    fMemberOfListviewAttachedData.Clear;
    for var lMemberOfEntry in aEntry.MemberOfList do
    begin
      var lMemberOfListItemData := default(TMemberOfListItemData);
      lMemberOfListItemData.MemberActive := lMemberOfEntry.PersonActive;
      var lItem := fMemberOfListviewAttachedData.AddItem(lMemberOfEntry.PersonNameId.Id, lMemberOfListItemData);
      lItem.Caption := lMemberOfEntry.PersonNameId.ToString;
    end;
  finally
    lvMemberOf.Items.EndUpdate;
  end;
end;

end.
