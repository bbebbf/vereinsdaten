unit unUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoUnit, DtoUnitAggregated, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, CheckboxDatetimePickerHandler, Vdm.Types,
  Vdm.Versioning.Types, VersionInfoEntryUI;

type
  TfraUnit = class(TFrame, ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TUnitFilter>, IVersionInfoEntryUI)
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
    lvMemberOf: TListView;
    cbShowInactiveUnits: TCheckBox;
    lbListviewItemCount: TLabel;
    pnTop: TPanel;
    lbTitle: TLabel;
    btReturn: TButton;
    pnTopRight: TPanel;
    lbUnitName: TLabel;
    lbUnitActiveSince: TLabel;
    lbUnitActiveUntil: TLabel;
    lbVersionInfo: TLabel;
    lbDataConfirmedOn: TLabel;
    edUnitName: TEdit;
    cbUnitActiveSinceKnown: TCheckBox;
    dtUnitActiveSince: TDateTimePicker;
    cbUnitActive: TCheckBox;
    dtUnitActiveUntil: TDateTimePicker;
    cbUnitActiveUntilKnown: TCheckBox;
    btSave: TButton;
    btReload: TButton;
    cbDataConfirmedOnKnown: TCheckBox;
    dtDataConfirmedOn: TDateTimePicker;
    procedure lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure cbShowInactiveUnitsClick(Sender: TObject);
    procedure btReturnClick(Sender: TObject);
    procedure lvListviewDblClick(Sender: TObject);
  strict private
    fReturnAction: TAction;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TUnitFilter>;
    fExtendedListview: TExtendedListview<TDtoUnit>;
    fExtendedListviewMemberOfs: TExtendedListview<TDtoUnitAggregatedPersonMemberOf>;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;
    fDataConfirmedOnHandler: TCheckboxDatetimePickerHandler;

    procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure StartEdit;
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    procedure EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TUnitFilter>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoUnit);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoUnitAggregated; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoUnitAggregated): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
  public
    constructor Create(AOwner: TComponent; const aReturnAction: TAction); reintroduce;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, StringTools, MessageDialogs, Vdm.Globals, VclUITools;

{ TfraUnit }

constructor TfraUnit.Create(AOwner: TComponent; const aReturnAction: TAction);
begin
  inherited Create(AOwner);
  fReturnAction := aReturnAction;
  fActiveSinceHandler := TCheckboxDatetimePickerHandler.Create(cbUnitActiveSinceKnown, dtUnitActiveSince);
  fActiveUntilHandler := TCheckboxDatetimePickerHandler.Create(cbUnitActiveUntilKnown, dtUnitActiveUntil);
  fDataConfirmedOnHandler := TCheckboxDatetimePickerHandler.Create(cbDataConfirmedOnKnown, dtDataConfirmedOn);

  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edUnitName);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActive);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActiveSinceKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtUnitActiveSince);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActiveUntilKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtUnitActiveUntil);
  fComponentValueChangedObserver.RegisterCheckbox(cbDataConfirmedOnKnown);
  fComponentValueChangedObserver.RegisterDateTimePicker(dtDataConfirmedOn);

  fExtendedListview := TExtendedListview<TDtoUnit>.Create(lvListview,
    procedure(const aData: TDtoUnit; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.ToString;
    end,
    TComparer<TDtoUnit>.Construct(
      function(const aLeft, aRight: TDtoUnit): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.Id, aRight.Id);
      end
    )
  );
  fExtendedListviewMemberOfs := TExtendedListview<TDtoUnitAggregatedPersonMemberOf>.Create(lvMemberOf,
    procedure(const aData: TDtoUnitAggregatedPersonMemberOf; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.PersonNameId.ToString;
      aListItem.SubItems.Add(aData.RoleName);
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.MemberActiveSince));
      aListItem.SubItems.Add(TVdmGlobals.GetActiveStateAsString(aData.MemberActive));
      aListItem.SubItems.Add(TVdmGlobals.GetDateAsString(aData.MemberActiveUntil));
    end,
    TComparer<TDtoUnitAggregatedPersonMemberOf>.Construct(
      function(const aLeft, aRight: TDtoUnitAggregatedPersonMemberOf): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.MemberRecordId, aRight.MemberRecordId);
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
end;

destructor TfraUnit.Destroy;
begin
  fDelayedLoadEntry.Free;
  fExtendedListviewMemberOfs.Free;
  fExtendedListview.Free;
  fComponentValueChangedObserver.Free;
  fDataConfirmedOnHandler.Free;
  fActiveSinceHandler.Free;
  fActiveUntilHandler.Free;
  inherited;
end;

procedure TfraUnit.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfraUnit.acSaveCurrentEntryExecute(Sender: TObject);
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

procedure TfraUnit.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  StartEdit;
end;

procedure TfraUnit.btReturnClick(Sender: TObject);
begin
  fReturnAction.Execute;
end;

procedure TfraUnit.cbShowInactiveUnitsClick(Sender: TObject);
begin
  var lListFilter := fBusinessIntf.ListFilter;
  lListFilter.ShowInactiveUnits := cbShowInactiveUnits.Checked;
  fBusinessIntf.ListFilter := lListFilter;
end;

procedure TfraUnit.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edUnitName.Text := '';
  cbUnitActive.Checked := True;
  fActiveSinceHandler.Clear;
  fActiveUntilHandler.Clear;
  fDataConfirmedOnHandler.Clear;
  fComponentValueChangedObserver.EndUpdate;
  lvMemberOf.Items.Clear;
end;

procedure TfraUnit.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfraUnit.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfraUnit.DeleteEntryFromUI(const aUnitId: UInt32);
begin

end;

function TfraUnit.GetEntryFromUI(var aEntry: TDtoUnitAggregated): Boolean;
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
  aEntry.DataConfirmedOn := fDataConfirmedOnHandler.Datetime;
end;

procedure TfraUnit.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TUnitFilter>);
begin
  fBusinessIntf := aCommands;
end;

procedure TfraUnit.LoadCurrentEntry(const aEntryId: UInt32);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  SetEditMode(False);
end;

procedure TfraUnit.ListEnumBegin;
begin
  fExtendedListview.BeginUpdate;
  fExtendedListview.Clear;
end;

procedure TfraUnit.ListEnumProcessItem(const aEntry: TDtoUnit);
begin
  fExtendedListview.Add(aEntry);
end;

procedure TfraUnit.ListEnumEnd;
begin
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
  fExtendedListview.EndUpdate;
  lbListviewItemCount.Caption := IntToStr(lvListview.Items.Count) + ' Datensätze';
  lvListview.SetFocus;
end;

procedure TfraUnit.lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lUnit: TDtoUnit;
  if fExtendedListview.TryGetListItemData(Item, lUnit) then
  begin
    if not lUnit.Active then
      Sender.Canvas.Font.Color := TVdmGlobals.GetInactiveColor;
  end;
end;

procedure TfraUnit.lvListviewDblClick(Sender: TObject);
begin
  if Assigned(lvListview.Selected) then
    EnqueueLoadEntry(lvListview.Selected, True);
end;

procedure TfraUnit.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
    EnqueueLoadEntry(Item, False)
  else
    EnqueueLoadEntry(nil, False);
end;

procedure TfraUnit.EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);
begin
  if fComponentValueChangedObserver.InUpdated then
    Exit;

  var lRecordFound := False;
  var lRecord: TDtoUnit;
  if Assigned(aListItem) then
  begin
    lRecordFound := fExtendedListview.TryGetListItemData(aListItem, lRecord);
  end;
  fDelayedLoadEntry.SetData(TDelayedLoadEntryData.Create(lRecord.Id, lRecordFound, aDoStartEdit));
end;

procedure TfraUnit.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lMemberOf: TDtoUnitAggregatedPersonMemberOf;
  if fExtendedListviewMemberOfs.TryGetListItemData(Item, lMemberOf) then
  begin
    if not lMemberOf.MemberActive then
      Sender.Canvas.Font.Color := TVdmGlobals.GetInactiveColor;
  end;
end;

procedure TfraUnit.SetEditMode(const aEditMode: Boolean);
begin
  var lInEditModeBefore := fInEditMode;
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
  if lInEditModeBefore and not fInEditMode then
    lvListview.SetFocus;
end;

procedure TfraUnit.SetEntryToUI(const aEntry: TDtoUnitAggregated; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edUnitName.Text := aEntry.Name;
  cbUnitActive.Checked := aEntry.Active;
  fActiveSinceHandler.Datetime := aEntry.ActiveSince;
  fActiveUntilHandler.Datetime := aEntry.ActiveUntil;
  fDataConfirmedOnHandler.Datetime := aEntry.DataConfirmedOn;

  fExtendedListview.UpdateData(aEntry.&Unit);

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

procedure TfraUnit.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, aVersionInfoEntry);
end;

procedure TfraUnit.StartEdit;
begin
  edUnitName.SetFocus;
  SetEditMode(True);
end;

procedure TfraUnit.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, nil);
end;

procedure TfraUnit.CMVisiblechanged(var Message: TMessage);
begin
  inherited;
  if Message.WParam = Ord(True) then
  begin
    alActionList.State := TActionListState.asNormal;
    SetEditMode(False);
  end
  else
  begin
    alActionList.State := TActionListState.asSuspended;
  end;
end;

end.
