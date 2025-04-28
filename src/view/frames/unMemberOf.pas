unit unMemberOf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.StdCtrls,
  ExtendedListview, DtoMember, DtoMemberAggregated, MemberOfUI, MemberOfBusinessIntf,
  unMemberOfsEditDlg, System.Actions, Vcl.ActnList, ListCrudCommands, Vcl.Menus,
  Vdm.Versioning.Types, VersionInfoEntryUI, KeyIndexStrings, WorkSection, ActionlistWrapper;

type
  TfraMemberOf = class(TFrame, IMemberOfUI, IVersionInfoEntryUI, IWorkSection)
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
    fDialog: TfmMemberOfsEditDlg;
    fAllDetailedItemsStringsData: TKeyIndexStringsData;
    fAllRolesStringsData: TKeyIndexStringsData;
    fActionlistWrapper: TActionlistWrapper;
    procedure SetCommands(const aCommands: IMemberOfBusinessIntf);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
    procedure ListEnumEnd;

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);

    function GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
    procedure UpdateEditItemActions(const aEnabled: Boolean);
    procedure UpdateListActions(const aEnabled: Boolean);

    procedure BeginWork;
    procedure EndWork;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetActionsEnabled(const aEnabled: Boolean);
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, System.DateUtils, Vdm.Globals, ListCrudCommands.Types, VclUITools, Vdm.Types,
  CrudCommands, MessageDialogs;

{ TfraPersonMemberOf }

procedure TfraMemberOf.acDeleteMemberOfExecute(Sender: TObject);
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

procedure TfraMemberOf.acEditMemberOfExecute(Sender: TObject);
begin
  var lSelectedItem := lvMemberOf.Selected;
  if not Assigned(lSelectedItem) then
    Exit;
  var lEntry: TListEntry<TDtoMemberAggregated>;
  if not fExtentedListviewMemberOfs.TryGetListItemData(lSelectedItem, lEntry) then
    Exit;

  if fDialog.Execute(fBusinessIntf.GetDetailItemTitle, lEntry.Data, False) then
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

procedure TfraMemberOf.acNewMemberOfExecute(Sender: TObject);
begin
  var lNewEntryCanceled := True;
  var lNewEntry := fBusinessIntf.CreateNewEntry;
  try
    if fDialog.Execute(fBusinessIntf.GetDetailItemTitle, lNewEntry.Data, True) then
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

procedure TfraMemberOf.acReloadMemberOfsExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadEntries;
  UpdateListActions(False);
end;

procedure TfraMemberOf.acSaveMemberOfsExecute(Sender: TObject);
begin
  var lResponse := fBusinessIntf.SaveEntries(
      procedure(const aEntry: TListEntry<TDtoMemberAggregated>)
      begin
        fExtentedListviewMemberOfs.Delete(aEntry);
      end
    );
  if lResponse.Status = TCrudSaveStatus.Successful then
  begin
    fExtentedListviewMemberOfs.InvalidateListItems;
    UpdateListActions(False);
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledWithMessage then
  begin
    TMessageDialogs.Ok(lResponse.MessageText, TMsgDlgType.mtInformation);
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledOnConflict then
  begin
    fExtentedListviewMemberOfs.InvalidateListItems;
    TMessageDialogs.Ok('Versionkonflikt: ' +
      lResponse.ConflictedVersionInfoEntry.ToString, TMsgDlgType.mtWarning);
  end;
end;

procedure TfraMemberOf.acShowInactiveMemberOfsExecute(Sender: TObject);
begin
  fBusinessIntf.ShowInactiveMemberOfs := acShowInactiveMemberOfs.Checked;
end;

procedure TfraMemberOf.BeginWork;
begin
  FreeAndNil(fAllDetailedItemsStringsData);
  FreeAndNil(fAllRolesStringsData);
end;

constructor TfraMemberOf.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fExtentedListviewMemberOfs := TExtendedListview<TListEntry<TDtoMemberAggregated>>.Create(lvMemberOf,
    procedure(const aData: TListEntry<TDtoMemberAggregated>; const aListItem: TListItem)
    begin
      if not Assigned(fAllDetailedItemsStringsData) then
        fAllDetailedItemsStringsData := aData.Data.AvailableDetailItems.Data.GetAllEntries;
      if not Assigned(fAllRolesStringsData) then
        fAllRolesStringsData := aData.Data.AvailableRoles.Data.GetAllEntries;

      aListItem.Caption := GetStringByIndex(fAllDetailedItemsStringsData.Strings,
        fAllDetailedItemsStringsData.Mapper.GetIndex(aData.Data.DetailItemId));
      aListItem.SubItems.Clear;
      aListItem.SubItems.Add(GetStringByIndex(fAllRolesStringsData.Strings,
        fAllRolesStringsData.Mapper.GetIndex(aData.Data.RoleId)));
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.Data.Member.ActiveSince));
      aListItem.SubItems.Add(TVdmGlobals.GetActiveStateAsString(aData.Data.Member.Active));
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.Data.Member.ActiveUntil));
      if fBusinessIntf.GetShowVersionInfoInMemberListview then
      begin
        aListItem.SubItems.Add(aData.Data.VersionInfoPersonMemberOf.ToString);
      end;
    end,
    TComparer<TListEntry<TDtoMemberAggregated>>.Construct(
      function(const aLeft, aRight: TListEntry<TDtoMemberAggregated>): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.Data.Id, aRight.Data.Id);
      end
    )
  );
  fExtentedListviewMemberOfs.OnCompareColumn := procedure(const aData1, aData2: TListEntry<TDtoMemberAggregated>;
    const aColumnIndex: Integer; var aCompareResult: Integer; var aHandled: Boolean)
  begin
      if fBusinessIntf.GetShowVersionInfoInMemberListview and (aColumnIndex = 5) then
      begin
        var lVersion1 := aData1.Data.VersionInfoPersonMemberOf.LocalVersionInfo.VersionNumber;
        var lVersion2 := aData2.Data.VersionInfoPersonMemberOf.LocalVersionInfo.VersionNumber;
        if lVersion1 < lVersion2 then
        begin
          aCompareResult := -1;
        end
        else if lVersion1 > lVersion2 then
        begin
          aCompareResult := 1;
        end
        else
        begin
          var lTimestamp1 := aData1.Data.VersionInfoPersonMemberOf.LocalVersionInfo.LastUpdated;
          var lTimestamp2 := aData2.Data.VersionInfoPersonMemberOf.LocalVersionInfo.LastUpdated;
          aCompareResult := CompareDateTime(lTimestamp1, lTimestamp2);
        end;
      end
      else
      begin
        aHandled := False;
      end;
  end;
  fDialog := TfmMemberOfsEditDlg.Create(Self);
  fActionlistWrapper := TActionlistWrapper.Create(alMemberOfsActionList);
end;

destructor TfraMemberOf.Destroy;
begin
  fAllRolesStringsData.Free;
  fAllDetailedItemsStringsData.Free;
  fDialog.Free;
  fExtentedListviewMemberOfs.Free;
  fActionlistWrapper.Free;
  inherited;
end;

procedure TfraMemberOf.EndWork;
begin

end;

procedure TfraMemberOf.SetActionsEnabled(const aEnabled: Boolean);
begin
  fActionlistWrapper.Enabled := aEnabled;
end;

procedure TfraMemberOf.SetCommands(const aCommands: IMemberOfBusinessIntf);
begin
  fBusinessIntf := aCommands;
  lbMemberOfsVersionInfo.Caption := '';
  lvMemberOf.Columns[0].Caption := fBusinessIntf.GetDetailItemTitle;
  if fBusinessIntf.GetShowVersionInfoInMemberListview then
  begin
    var lColumn := lvMemberOf.Columns.Add;
    lColumn.Caption := 'Version';
    lColumn.Width := 220;
  end;
end;

procedure TfraMemberOf.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbMemberOfsVersionInfo, nil);
end;

procedure TfraMemberOf.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbMemberOfsVersionInfo, aVersionInfoEntry);
end;

procedure TfraMemberOf.ListEnumBegin;
begin
  UpdateEditItemActions(False);
  UpdateListActions(False);
  lbMemberOfsVersionInfo.Caption := '';
  fExtentedListviewMemberOfs.BeginUpdate;
  fExtentedListviewMemberOfs.Clear;
end;

procedure TfraMemberOf.ListEnumEnd;
begin
  fExtentedListviewMemberOfs.EndUpdate;
end;

procedure TfraMemberOf.ListEnumProcessItem(const aItem: TListEntry<TDtoMemberAggregated>);
begin
  fExtentedListviewMemberOfs.Add(aItem);
end;

procedure TfraMemberOf.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
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

procedure TfraMemberOf.lvMemberOfDblClick(Sender: TObject);
begin
  if Assigned(lvMemberOf.Selected) then
    acEditMemberOf.Execute;
end;

procedure TfraMemberOf.lvMemberOfSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  UpdateEditItemActions(Assigned(Item) and Selected);
end;

procedure TfraMemberOf.UpdateEditItemActions(const aEnabled: Boolean);
begin
  fActionlistWrapper.SetActionEnabled(acEditMemberOf, aEnabled);
  fActionlistWrapper.SetActionEnabled(acDeleteMemberOf, aEnabled);
end;

procedure TfraMemberOf.UpdateListActions(const aEnabled: Boolean);
begin
  fActionlistWrapper.SetActionEnabled(acSaveMemberOfs, aEnabled);
  fActionlistWrapper.SetActionEnabled(acReloadMemberOfs, aEnabled);
end;

function TfraMemberOf.GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
begin
  if (0 <= aIndex) and (aIndex < aStrings.Count) then
    Result := aStrings[aIndex]
  else
    Result := '';
end;

end.
