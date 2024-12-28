unit unPersonMemberOf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  ListviewAttachedData, DtoMember, DtoMemberAggregated, PersonMemberOfUI, MemberOfBusinessIntf,
  unPersonMemberOfsEditDlg, System.Actions, Vcl.ActnList, ListCrudCommands, Vcl.Menus;

type
  TfraPersonMemberOf = class(TFrame, IPersonMemberOfUI)
    lvMemberOf: TListView;
    pnCommands: TPanel;
    cbShowInactiveMemberOfs: TCheckBox;
    alMemberOfsActionList: TActionList;
    acNewMemberOf: TAction;
    acEditMemberOf: TAction;
    acDeleteMemberOf: TAction;
    acSaveMemberOfs: TAction;
    acReloadMemberOfs: TAction;
    acShowInactiveMemberOfs: TAction;
    btSaveMemberOfs: TButton;
    btReloadMemberOfs: TButton;
    btNewMemberOf: TButton;
    btEditMemberOf: TButton;
    btDeleteMemberOf: TButton;
    PopupMenu: TPopupMenu;
    Verbindunghinzufgen1: TMenuItem;
    N1: TMenuItem;
    Verbindungbearbeiten1: TMenuItem;
    Verbindungentfernen1: TMenuItem;
    procedure lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure acShowInactiveMemberOfsExecute(Sender: TObject);
    procedure acEditMemberOfExecute(Sender: TObject);
    procedure lvMemberOfDblClick(Sender: TObject);
    procedure lvMemberOfSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acNewMemberOfExecute(Sender: TObject);
    procedure acDeleteMemberOfExecute(Sender: TObject);
    procedure acReloadMemberOfsExecute(Sender: TObject);
    procedure acSaveMemberOfsExecute(Sender: TObject);
  private
    fBusinessIntf: IMemberOfBusinessIntf;
    fMemberOfListviewAttachedData: TListviewAttachedData<UInt32, TListEntry<TDtoMemberAggregated>>;
    fDialog: TfmPersonMemberOfsEditDlg;
    procedure SetCommands(const aCommands: IMemberOfBusinessIntf);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
    procedure ListEnumEnd;

    procedure MemberEntryToListItem(const aEntry: TListEntry<TDtoMemberAggregated>; const aListItem: TListItem);
    function GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
    procedure UpdateEditItemActions(const aEnabled: Boolean);
    procedure UpdateListActions(const aEnabled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses Vdm.Globals, ListCrudCommands.Types;

{ TfraPersonMemberOf }

procedure TfraPersonMemberOf.acDeleteMemberOfExecute(Sender: TObject);
begin
  var lSelectedItem := lvMemberOf.Selected;
  if not Assigned(lSelectedItem) then
    Exit;
  var lEntry: TListEntry<TDtoMemberAggregated>;
  if not fMemberOfListviewAttachedData.TryGetExtraData(lSelectedItem, lEntry) then
    Exit;

  lEntry.ToggleToBeDeleted;
  MemberEntryToListItem(lEntry, lSelectedItem);
  UpdateListActions(True);
end;

procedure TfraPersonMemberOf.acEditMemberOfExecute(Sender: TObject);
begin
  var lSelectedItem := lvMemberOf.Selected;
  if not Assigned(lSelectedItem) then
    Exit;
  var lEntry: TListEntry<TDtoMemberAggregated>;
  if not fMemberOfListviewAttachedData.TryGetExtraData(lSelectedItem, lEntry) then
    Exit;
  if fDialog.Execute(lEntry.Data, False) then
  begin
    if lEntry.State in [TListEntryCrudState.New, TListEntryCrudState.ToBeDeleted] then
    begin
      lEntry.ToggleToBeDeleted;
    end;
    lEntry.Updated;
    MemberEntryToListItem(lEntry, lSelectedItem);
    UpdateListActions(True);
  end;
end;

procedure TfraPersonMemberOf.acNewMemberOfExecute(Sender: TObject);
begin
  var lNewEntryCanceled := True;
  var lNewEntry := fBusinessIntf.CreateNewEntry;
  try
    if fDialog.Execute(lNewEntry.Data, True) then
    begin
      lNewEntry.Updated;
      lNewEntryCanceled := False;
      MemberEntryToListItem(lNewEntry, nil);
      fBusinessIntf.AddNewEntry(lNewEntry);
      UpdateListActions(True);
  end;
  finally
    if lNewEntryCanceled then
      lNewEntry.Free;
  end;
end;

procedure TfraPersonMemberOf.acReloadMemberOfsExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadEntries;
  UpdateListActions(False);
end;

procedure TfraPersonMemberOf.acSaveMemberOfsExecute(Sender: TObject);
begin
  fBusinessIntf.SaveEntries(
      procedure(const aEntry: TListEntry<TDtoMemberAggregated>)
      begin
        var lItem: TListItem;
        if fMemberOfListviewAttachedData.TryGetItem(aEntry.Data.Id, lItem) then
          lvMemberOf.Items.Delete(lItem.Index);
      end
    );
  UpdateListActions(False);
end;

procedure TfraPersonMemberOf.acShowInactiveMemberOfsExecute(Sender: TObject);
begin
  fBusinessIntf.ShowInactiveMemberOfs := acShowInactiveMemberOfs.Checked;
end;

constructor TfraPersonMemberOf.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMemberOfListviewAttachedData := TListviewAttachedData<UInt32, TListEntry<TDtoMemberAggregated>>.Create(lvMemberOf);
  fDialog := TfmPersonMemberOfsEditDlg.Create(Self);
end;

destructor TfraPersonMemberOf.Destroy;
begin
  fDialog.Free;
  fMemberOfListviewAttachedData.Free;
  inherited;
end;

procedure TfraPersonMemberOf.SetCommands(const aCommands: IMemberOfBusinessIntf);
begin
  fBusinessIntf := aCommands;
end;

procedure TfraPersonMemberOf.ListEnumBegin;
begin
  UpdateEditItemActions(False);
  UpdateListActions(False);
  lvMemberOf.Items.BeginUpdate;
  fMemberOfListviewAttachedData.Clear;
end;

procedure TfraPersonMemberOf.ListEnumEnd;
begin
  lvMemberOf.Items.EndUpdate;
end;

procedure TfraPersonMemberOf.ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
begin
  MemberEntryToListItem(aItem, nil);
end;

procedure TfraPersonMemberOf.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
  var lMemberOfListItemData: TListEntry<TDtoMemberAggregated> := nil;
  if not fMemberOfListviewAttachedData.TryGetExtraData(Item, lMemberOfListItemData) then
    Exit;

  var lColor: TColor;
  if TVdmGlobals.TryGetColorForCrudState(lMemberOfListItemData.State, lColor) then
  begin
    Sender.Canvas.Font.Color := lColor;
    Exit;
  end;

  if not lMemberOfListItemData.Data.Member.Active then
    Sender.Canvas.Font.Color := TVdmGlobals.GetInactiveColor;
end;

procedure TfraPersonMemberOf.lvMemberOfDblClick(Sender: TObject);
begin
  if Assigned(lvMemberOf.Selected) then
    acEditMemberOf.Execute;
end;

procedure TfraPersonMemberOf.lvMemberOfSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  UpdateEditItemActions(Assigned(Item) and Selected);
end;

procedure TfraPersonMemberOf.MemberEntryToListItem(const aEntry: TListEntry<TDtoMemberAggregated>; const aListItem: TListItem);
begin
  var lListItem := aListItem;
  if Assigned(lListItem) then
  begin
    fMemberOfListviewAttachedData.UpdateItem(lListItem, aEntry.Data.Id, aEntry);
  end
  else
  begin
    lListItem := fMemberOfListviewAttachedData.AddItem(aEntry.Data.Id, aEntry);
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
    lListItem.SubItems.Add('');
  end;
  lListItem.Caption := GetStringByIndex(aEntry.Data.AvailableUnits.Data.Strings, aEntry.Data.UnitIndex);
  lListItem.SubItems[0] := GetStringByIndex(aEntry.Data.AvailableRoles.Data.Strings, aEntry.Data.RoleIndex);
  lListItem.SubItems[1] := TVdmGlobals.GetDateAsString(aEntry.Data.Member.ActiveSince);
  lListItem.SubItems[2] := TVdmGlobals.GetActiveStateAsString(aEntry.Data.Member.Active);
  lListItem.SubItems[3] := TVdmGlobals.GetDateAsString(aEntry.Data.Member.ActiveUntil);
end;

procedure TfraPersonMemberOf.UpdateEditItemActions(const aEnabled: Boolean);
begin
  acEditMemberOf.Enabled := aEnabled;
  acDeleteMemberOf.Enabled := aEnabled;
end;

procedure TfraPersonMemberOf.UpdateListActions(const aEnabled: Boolean);
begin
  acSaveMemberOfs.Enabled := aEnabled;
  acReloadMemberOfs.Enabled := aEnabled;
end;

function TfraPersonMemberOf.GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
begin
  if (0 <= aIndex) and (aIndex < aStrings.Count) then
    Result := aStrings[aIndex]
  else
    Result := '';
end;

end.
