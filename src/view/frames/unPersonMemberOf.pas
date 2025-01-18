unit unPersonMemberOf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  ExtendedListview, DtoMember, DtoMemberAggregated, PersonMemberOfUI, MemberOfBusinessIntf,
  unPersonMemberOfsEditDlg, System.Actions, Vcl.ActnList, ListCrudCommands, Vcl.Menus,
  Vdm.Versioning.Types, VersionInfoEntryUI;

type
  TfraPersonMemberOf = class(TFrame, IPersonMemberOfUI, IVersionInfoEntryUI)
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
    lbMemberOfsVersionInfo: TLabel;
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
    fExtentedListviewMemberOfs: TExtendedListview<TListEntry<TDtoMemberAggregated>>;
    fDialog: TfmPersonMemberOfsEditDlg;
    procedure SetCommands(const aCommands: IMemberOfBusinessIntf);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
    procedure ListEnumEnd;

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);

    function GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
    procedure UpdateEditItemActions(const aEnabled: Boolean);
    procedure UpdateListActions(const aEnabled: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetActionsEnabled(const aEnabled: Boolean);
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, Vdm.Globals, ListCrudCommands.Types, VclUITools;

{ TfraPersonMemberOf }

procedure TfraPersonMemberOf.acDeleteMemberOfExecute(Sender: TObject);
begin
  var lSelectedItem := lvMemberOf.Selected;
  if not Assigned(lSelectedItem) then
    Exit;
  var lEntry: TListEntry<TDtoMemberAggregated>;
  if not fExtentedListviewMemberOfs.TryGetListItemData(lSelectedItem, lEntry) then
    Exit;

  lEntry.ToggleToBeDeleted;
  fExtentedListviewMemberOfs.UpdateData(lEntry);
  UpdateListActions(True);
end;

procedure TfraPersonMemberOf.acEditMemberOfExecute(Sender: TObject);
begin
  var lSelectedItem := lvMemberOf.Selected;
  if not Assigned(lSelectedItem) then
    Exit;
  var lEntry: TListEntry<TDtoMemberAggregated>;
  if not fExtentedListviewMemberOfs.TryGetListItemData(lSelectedItem, lEntry) then
    Exit;

  if fDialog.Execute(lEntry.Data, False) then
  begin
    if lEntry.State in [TListEntryCrudState.New, TListEntryCrudState.ToBeDeleted] then
    begin
      lEntry.ToggleToBeDeleted;
    end;
    lEntry.Updated;
    fExtentedListviewMemberOfs.UpdateData(lEntry);
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
      fExtentedListviewMemberOfs.Add(lNewEntry);
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
        if fExtentedListviewMemberOfs.TryGetListItem(aEntry, lItem) then
          lItem.Delete;
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
  fExtentedListviewMemberOfs := TExtendedListview<TListEntry<TDtoMemberAggregated>>.Create(lvMemberOf,
    procedure(const aData: TListEntry<TDtoMemberAggregated>; const aListItem: TListItem)
    begin
      aListItem.Caption := GetStringByIndex(aData.Data.AvailableUnits.Data.Strings, aData.Data.UnitIndex);
      aListItem.SubItems.Clear;
      aListItem.SubItems.Add(GetStringByIndex(aData.Data.AvailableRoles.Data.Strings, aData.Data.RoleIndex));
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.Data.Member.ActiveSince));
      aListItem.SubItems.Add(TVdmGlobals.GetActiveStateAsString(aData.Data.Member.Active));
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.Data.Member.ActiveUntil));
    end,
    TComparer<TListEntry<TDtoMemberAggregated>>.Construct(
      function(const aLeft, aRight: TListEntry<TDtoMemberAggregated>): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.Data.Id, aRight.Data.Id);
      end
    )
  );
  fDialog := TfmPersonMemberOfsEditDlg.Create(Self);
end;

destructor TfraPersonMemberOf.Destroy;
begin
  fDialog.Free;
  fExtentedListviewMemberOfs.Free;
  inherited;
end;

procedure TfraPersonMemberOf.SetActionsEnabled(const aEnabled: Boolean);
begin
  if aEnabled then
  begin
    alMemberOfsActionList.State := TActionListState.asNormal;
  end
  else
  begin
    alMemberOfsActionList.State := TActionListState.asSuspended;
  end;
end;

procedure TfraPersonMemberOf.SetCommands(const aCommands: IMemberOfBusinessIntf);
begin
  fBusinessIntf := aCommands;
end;

procedure TfraPersonMemberOf.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbMemberOfsVersionInfo, nil);
end;

procedure TfraPersonMemberOf.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbMemberOfsVersionInfo, aVersionInfoEntry);
end;

procedure TfraPersonMemberOf.ListEnumBegin;
begin
  UpdateEditItemActions(False);
  UpdateListActions(False);
  lbMemberOfsVersionInfo.Caption := '';
  fExtentedListviewMemberOfs.BeginUpdate;
  fExtentedListviewMemberOfs.Clear;
end;

procedure TfraPersonMemberOf.ListEnumEnd;
begin
  fExtentedListviewMemberOfs.EndUpdate;
end;

procedure TfraPersonMemberOf.ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
begin
  fExtentedListviewMemberOfs.Add(aItem);
end;

procedure TfraPersonMemberOf.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
  var lMemberOfListItemData: TListEntry<TDtoMemberAggregated> := nil;
  if not fExtentedListviewMemberOfs.TryGetListItemData(Item, lMemberOfListItemData) then
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
