unit unUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoUnit, DtoUnitAggregated, ListviewAttachedData, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, DelayedExecute, CheckboxDatetimePickerHandler, Vdm.Types,
  Vdm.Versioning.Types, VersionInfoEntryUI;

type
  TUnitListItemData = record
    UnitActive: Boolean;
  end;

  TMemberOfListItemData = record
    MemberActive: Boolean;
  end;

  TfmUnit = class(TForm, ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>, IVersionInfoEntryUI)
    pnListview: TPanel;
    Splitter1: TSplitter;
    pnDetails: TPanel;
    lvListview: TListView;
    alActionList: TActionList;
    acSaveCurrentEntry: TAction;
    acReloadCurrentEntry: TAction;
    pnFilter: TPanel;
    acStartNewEntry: TAction;
    btStartNewRecord: TButton;
    lbUnitName: TLabel;
    edUnitName: TEdit;
    cbUnitActiveSinceKnown: TCheckBox;
    dtUnitActiveSince: TDateTimePicker;
    lbUnitActiveSince: TLabel;
    cbUnitActive: TCheckBox;
    lbUnitActiveUntil: TLabel;
    dtUnitActiveUntil: TDateTimePicker;
    cbUnitActiveUntilKnown: TCheckBox;
    btSave: TButton;
    btReload: TButton;
    lvMemberOf: TListView;
    cbShowInactiveUnits: TCheckBox;
    lbListviewItemCount: TLabel;
    lbVersionInfo: TLabel;
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
    procedure cbShowInactiveUnitsClick(Sender: TObject);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TUnitFilter>;
    fListviewAttachedData: TListviewAttachedData<UInt32, TUnitListItemData>;
    fMemberOfListviewAttachedData: TListviewAttachedData<UInt32, TMemberOfListItemData>;
    fDelayedExecute: TDelayedExecute<TPair<Boolean, UInt32>>;
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    function EntryToListItem(const aEntry: TDtoUnit; const aItem: TListItem): TListItem;

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TUnitFilter>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoUnit);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoUnitAggregated; const aAsNewEntry: Boolean);
    function GetEntryFromUI(var aEntry: TDtoUnitAggregated): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses StringTools, MessageDialogs, Vdm.Globals, VclUITools;

{ TfmUnit }

procedure TfmUnit.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfmUnit.acSaveCurrentEntryExecute(Sender: TObject);
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

procedure TfmUnit.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  SetEditMode(False);
end;

procedure TfmUnit.cbShowInactiveUnitsClick(Sender: TObject);
begin
  var lListFilter := fBusinessIntf.ListFilter;
  lListFilter.ShowInactiveUnits := cbShowInactiveUnits.Checked;
  fBusinessIntf.ListFilter := lListFilter;
end;

procedure TfmUnit.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edUnitName.Text := '';
  cbUnitActive.Checked := True;
  fActiveSinceHandler.Clear;
  fActiveUntilHandler.Clear;
  fComponentValueChangedObserver.EndUpdate;
  lvMemberOf.Items.Clear;
end;

procedure TfmUnit.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmUnit.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmUnit.DeleteEntryFromUI(const aUnitId: UInt32);
begin

end;

procedure TfmUnit.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;

  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

procedure TfmUnit.FormCreate(Sender: TObject);
begin
  fActiveSinceHandler := TCheckboxDatetimePickerHandler.Create(cbUnitActiveSinceKnown, dtUnitActiveSince);
  fActiveUntilHandler := TCheckboxDatetimePickerHandler.Create(cbUnitActiveUntilKnown, dtUnitActiveUntil);

  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edUnitName);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActive);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActiveSinceKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtUnitActiveSince);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActiveUntilKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtUnitActiveUntil);

  fListviewAttachedData := TListviewAttachedData<UInt32, TUnitListItemData>.Create(lvListview);
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

procedure TfmUnit.FormDestroy(Sender: TObject);
begin
  fActiveSinceHandler.Free;
  fActiveUntilHandler.Free;
  fDelayedExecute.Free;
  fMemberOfListviewAttachedData.Free;
  fListviewAttachedData.Free;
  fComponentValueChangedObserver.Free;
end;

function TfmUnit.GetEntryFromUI(var aEntry: TDtoUnitAggregated): Boolean;
begin
  if TStringTools.IsEmpty(edUnitName.Text) then
  begin
    edUnitName.SetFocus;
    TMessageDialogs.Ok('Die Bezeichnung muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Name := edUnitName.Text;
  aEntry.Active := cbUnitActive.Checked;
  aEntry.ActiveSince := fActiveSinceHandler.Datetime;
  aEntry.ActiveUntil := fActiveUntilHandler.Datetime;
end;

procedure TfmUnit.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TUnitFilter>);
begin
  fBusinessIntf := aCommands;
end;

procedure TfmUnit.LoadCurrentEntry(const aEntryId: UInt32);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  SetEditMode(False);
end;

procedure TfmUnit.ListEnumBegin;
begin
  lvListview.Items.BeginUpdate;
  fListviewAttachedData.Clear;
end;

procedure TfmUnit.ListEnumProcessItem(const aEntry: TDtoUnit);
begin
  EntryToListItem(aEntry, nil);
end;

procedure TfmUnit.ListEnumEnd;
begin
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
  lvListview.Items.EndUpdate;
  lbListviewItemCount.Caption := IntToStr(lvListview.Items.Count) + ' Datensätze';
  lvListview.SetFocus;
end;

procedure TfmUnit.lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lListItemData: TUnitListItemData;
  if fListviewAttachedData.TryGetExtraData(Item, lListItemData) then
  begin
    if not lListItemData.UnitActive then
      Sender.Canvas.Font.Color := clLtGray;
  end;
end;

procedure TfmUnit.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  var lEntryFound := False;
  var lEntryId: UInt32 := 0;
  if Selected then
  begin
    lEntryFound := fListviewAttachedData.TryGetKey(Item, lEntryId);
  end;

  fDelayedExecute.SetData(TPair<Boolean, UInt32>.Create(lEntryFound, lEntryId));
end;

procedure TfmUnit.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
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

function TfmUnit.EntryToListItem(const aEntry: TDtoUnit; const aItem: TListItem): TListItem;
begin
  var lItemData := default(TUnitListItemData);
  lItemData.UnitActive := aEntry.Active;
  Result := aItem;
  if Assigned(Result) then
  begin
    fListviewAttachedData.UpdateItem(aItem, aEntry.Id, lItemData);
  end
  else
  begin
    Result := fListviewAttachedData.AddItem(aEntry.Id, lItemData);
  end;
  Result.Caption := aEntry.ToString;
end;

procedure TfmUnit.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
end;

procedure TfmUnit.SetEntryToUI(const aEntry: TDtoUnitAggregated; const aAsNewEntry: Boolean);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edUnitName.Text := aEntry.Name;
  cbUnitActive.Checked := aEntry.Active;
  fActiveSinceHandler.Datetime := aEntry.ActiveSince;
  fActiveUntilHandler.Datetime := aEntry.ActiveUntil;

  if aAsNewEntry then
  begin
    var lNewItem := EntryToListItem(aEntry.&Unit, nil);
    lNewItem.Selected := True;
    lNewItem.MakeVisible(False);
  end
  else
  begin
    EntryToListItem(aEntry.&Unit, lvListview.Selected);
  end;

  fComponentValueChangedObserver.EndUpdate;

  lvMemberOf.Items.BeginUpdate;
  try
    fMemberOfListviewAttachedData.Clear;
    for var lMemberOfEntry in aEntry.MemberOfList do
    begin
      var lMemberOfListItemData := default(TMemberOfListItemData);
      lMemberOfListItemData.MemberActive := lMemberOfEntry.MemberActive;
      var lItem := fMemberOfListviewAttachedData.AddItem(lMemberOfEntry.PersonNameId.Id, lMemberOfListItemData);
      lItem.Caption := lMemberOfEntry.PersonNameId.ToString;
      lItem.SubItems.Add(lMemberOfEntry.RoleName);
      lItem.SubItems.Add(TVdmGlobals.GetDateAsString(lMemberOfEntry.MemberActiveSince));
      lItem.SubItems.Add(TVdmGlobals.GetActiveStateAsString(lMemberOfEntry.MemberActive));
      lItem.SubItems.Add(TVdmGlobals.GetDateAsString(lMemberOfEntry.MemberActiveUntil));
    end;
  finally
    lvMemberOf.Items.EndUpdate;
  end;
end;

procedure TfmUnit.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, aVersionInfoEntry);
end;

procedure TfmUnit.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, nil);
end;

end.
