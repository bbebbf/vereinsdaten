unit unAddress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoAddress, DtoAddressAggregated, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, Vdm.Types, Vdm.Versioning.Types, VersionInfoEntryUI, ProgressIndicatorIntf;

type
  TfmAddress = class(TForm, ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TEntryFilter>, IVersionInfoEntryUI)
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
    lbVersionInfo: TLabel;
    cbAddressActive: TCheckBox;
    cbShowInactiveEntries: TCheckBox;
    edFilter: TEdit;
    lbFilter: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure lvListviewDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure cbShowInactiveEntriesClick(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  strict private
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TEntryFilter>;
    fExtendedListview: TExtendedListview<TDtoAddress, UInt32>;
    fExtendedListviewMemberOfs: TExtendedListview<TDtoAddressAggregatedPersonMemberOf, UInt32>;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fProgressIndicator: IProgressIndicator;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure StartEdit;
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    procedure EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TEntryFilter>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoAddress);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aAddressId: UInt32);
    procedure ClearEntryFromUI;
    function SetSelectedEntry(const aAddressId: UInt32): Boolean;
    procedure SetEntryToUI(const aEntry: TDtoAddressAggregated; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoAddressAggregated; const aMode: TUIToEntryMode;
      const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);
    function GetProgressIndicator: IProgressIndicator;

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, StringTools, MessageDialogs, Vdm.Globals, VclUITools;

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
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledOnConflict then
  begin
    TMessageDialogs.Ok('Versionkonflikt: ' +
      lResponse.ConflictedVersionInfoEntry.ToString, TMsgDlgType.mtWarning);
  end;
end;

procedure TfmAddress.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  SetEditMode(False);
end;

procedure TfmAddress.cbShowInactiveEntriesClick(Sender: TObject);
begin
  var lListFilter := fBusinessIntf.ListFilter;
  lListFilter.ShowInactiveEntries := cbShowInactiveEntries.Checked;
  fBusinessIntf.ListFilter := lListFilter;
end;

procedure TfmAddress.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edAddressStreet.Text := '';
  edAddressPostalcode.Text := '';
  edAddressCity.Text := '';
  cbAddressActive.Checked := True;
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

procedure TfmAddress.DeleteEntryFromUI(const aAddressId: UInt32);
begin

end;

procedure TfmAddress.edFilterChange(Sender: TObject);
begin
  const lEmptyFilter = Length(edFilter.Text) = 0;
  fExtendedListview.Filter<string>(LowerCase(edFilter.Text),
    function(const aFilterExpression: string; const aData: TDtoAddress): Boolean
    begin
      Result := lEmptyFilter or (Pos(aFilterExpression, LowerCase(aData.ToString)) > 0);
    end
  );
end;

procedure TfmAddress.FormCreate(Sender: TObject);
begin
  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edAddressStreet);
  fComponentValueChangedObserver.RegisterEdit(edAddressPostalcode);
  fComponentValueChangedObserver.RegisterEdit(edAddressCity);
  fComponentValueChangedObserver.RegisterCheckbox(cbAddressActive);

  fExtendedListview := TExtendedListview<TDtoAddress, UInt32>.Create(lvListview,
    procedure(const aData: TDtoAddress; const aListItem: TListItem)
    begin
      {$ifdef INTERNAL_DB_ID_VISIBLE}
        aListItem.Caption := aData.City + ' (' + IntToStr(aData.Id) + ')';
      {$else}
        aListItem.Caption := aData.City;
      {$endif}
      aListItem.SubItems.Clear;
      aListItem.SubItems.Add(aData.Street);
      aListItem.SubItems.Add(aData.Postalcode);
    end,
    function(const aData: TDtoAddress): UInt32
    begin
      Result := aData.Id;
    end,
    TComparer<UInt32>.Construct(
      function(const aLeft, aRight: UInt32): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft, aRight);
      end
    )
  );
  fExtendedListviewMemberOfs := TExtendedListview<TDtoAddressAggregatedPersonMemberOf, UInt32>.Create(lvMemberOf,
    procedure(const aData: TDtoAddressAggregatedPersonMemberOf; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.PersonNameId.ToString;
    end,
    function(const aData: TDtoAddressAggregatedPersonMemberOf): UInt32
    begin
      Result := aData.PersonNameId.Id;
    end,
    TComparer<UInt32>.Construct(
      function(const aLeft, aRight: UInt32): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft, aRight);
      end
    )
  );

  fDelayedLoadEntry := TDelayedLoadEntry.Create(
    procedure(const aData: TDelayedLoadEntryData)
    begin
      if aData.RecordFound then
      begin
        LoadCurrentEntry(aData.RecordId);
        if aData.StartEdit then
          StartEdit;
      end
      else
      begin
        ClearEntryFromUI;
      end;
    end,
    200
  );

  lbVersionInfo.Caption := '';
end;

procedure TfmAddress.FormDestroy(Sender: TObject);
begin
  fDelayedLoadEntry.Free;
  fExtendedListviewMemberOfs.Free;
  fExtendedListview.Free;
  fComponentValueChangedObserver.Free;
end;

procedure TfmAddress.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) and not fInEditMode then
  begin
    Key := #0;
    Close;
  end;
end;

procedure TfmAddress.FormShow(Sender: TObject);
begin
  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

function TfmAddress.GetEntryFromUI(var aEntry: TDtoAddressAggregated; const aMode: TUIToEntryMode;
  const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
begin
  if TStringTools.IsEmpty(edAddressCity.Text) then
  begin
    edAddressCity.SetFocus;
    aProgressUISuspendScope.Suspend;
    TMessageDialogs.Ok('Der Ortsname muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Street := edAddressStreet.Text;
  aEntry.Postalcode := edAddressPostalcode.Text;
  aEntry.City := edAddressCity.Text;
  aEntry.Active := cbAddressActive.Checked;
end;

function TfmAddress.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

procedure TfmAddress.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TEntryFilter>);
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
  fExtendedListview.BeginUpdate;
  fExtendedListview.Clear;
end;

procedure TfmAddress.ListEnumProcessItem(const aEntry: TDtoAddress);
begin
  fExtendedListview.Add(aEntry);
end;

procedure TfmAddress.ListEnumEnd;
begin
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
  fExtendedListview.EndUpdate;
  lbListviewItemCount.Caption := IntToStr(lvListview.Items.Count) + ' Datensätze';
  lvListview.SetFocus;
end;

procedure TfmAddress.lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lAddress: TDtoAddress;
  if fExtendedListview.TryGetListItemData(Item, lAddress) then
  begin
    if not lAddress.Active then
      Sender.Canvas.Font.Color := TVdmGlobals.GetInactiveColor;
  end;
end;

procedure TfmAddress.lvListviewDblClick(Sender: TObject);
begin
  if Assigned(lvListview.Selected) then
    EnqueueLoadEntry(lvListview.Selected, True);
end;

procedure TfmAddress.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
    EnqueueLoadEntry(Item, False)
  else
    EnqueueLoadEntry(nil, False);
end;

procedure TfmAddress.EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);
begin
  if fComponentValueChangedObserver.InUpdated then
    Exit;

  var lRecordFound := False;
  var lRecord: TDtoAddress;
  if Assigned(aListItem) then
  begin
    lRecordFound := fExtendedListview.TryGetListItemData(aListItem, lRecord);
  end;
  fDelayedLoadEntry.SetData(TDelayedLoadEntryData.Create(lRecord.Id, lRecordFound, aDoStartEdit));
end;

procedure TfmAddress.SetEditMode(const aEditMode: Boolean);
begin
  var lInEditModeBefore := fInEditMode;
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
  acDeleteCurrentEntry.Enabled := not fInEditMode;
  if lInEditModeBefore and not fInEditMode then
    lvListview.SetFocus;
end;

procedure TfmAddress.SetEntryToUI(const aEntry: TDtoAddressAggregated; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edAddressStreet.Text := aEntry.Street;
  edAddressPostalcode.Text := aEntry.Postalcode;
  edAddressCity.Text := aEntry.City;
  cbAddressActive.Checked := aEntry.Active;
  fExtendedListview.UpdateData(aEntry.Address);

  fComponentValueChangedObserver.EndUpdate;

  fExtendedListviewMemberOfs.BeginUpdate;
  try
    fExtendedListviewMemberOfs.Clear;
    for var lMemberOfEntry in aEntry.MemberOfList do
    begin
      fExtendedListviewMemberOfs.Add(lMemberOfEntry);
    end;
  finally
    fExtendedListviewMemberOfs.EndUpdate;
  end;
end;

function TfmAddress.SetSelectedEntry(const aAddressId: UInt32): Boolean;
begin
  Result := False;
end;

procedure TfmAddress.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, aVersionInfoEntry);
end;

procedure TfmAddress.StartEdit;
begin
  edAddressStreet.SetFocus;
  SetEditMode(True);
end;

procedure TfmAddress.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, nil);
end;

end.
