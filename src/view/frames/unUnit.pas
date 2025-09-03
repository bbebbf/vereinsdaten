unit unUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoUnit, DtoUnitAggregated, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, Vdm.Types,
  Vdm.Versioning.Types, VersionInfoEntryUI, MemberOfUI, unMemberOf, ProgressIndicatorIntf, WorkSection,
  ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, ValidatableValueControlsRegistry;

type
  TfraUnit = class(TFrame, ICrudUI<TDtoUnitAggregated, TDtoUnit, UInt32, TEntryFilter>, IVersionInfoEntryUI, IWorkSection)
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
    cbShowInactiveUnits: TCheckBox;
    lbListviewItemCount: TLabel;
    pnTop: TPanel;
    lbTitle: TLabel;
    pnTopRight: TPanel;
    lbUnitName: TLabel;
    lbUnitActiveSince: TLabel;
    lbUnitActiveUntil: TLabel;
    lbVersionInfo: TLabel;
    lbDataConfirmedOn: TLabel;
    edUnitName: TEdit;
    cbUnitActive: TCheckBox;
    btSave: TButton;
    btReload: TButton;
    pnMemberOf: TPanel;
    lbFilter: TLabel;
    edFilter: TEdit;
    cbUnitKind: TComboBox;
    lbUnitKind: TLabel;
    deUnitActiveSince: TDateEdit;
    deUnitActiveUntil: TDateEdit;
    deDataConfirmedOn: TDateEdit;
    pnBelowList: TPanel;
    cbEnableCheckboxes: TCheckBox;
    procedure lvListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure cbShowInactiveUnitsClick(Sender: TObject);
    procedure lvListviewDblClick(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure cbEnableCheckboxesClick(Sender: TObject);
  strict private
    fUnitMemberOf: TfraMemberOf;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TEntryFilter>;
    fExtendedListview: TExtendedListview<TDtoUnit, UInt32>;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fProgressIndicator: IProgressIndicator;
    fCurrentUnitId: UInt32;
    fValidatableValueControlsRegistry: TValidatableValueControlsRegistry;

    procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure StartEdit;
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    procedure EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);

    procedure BeginWork;
    procedure EndWork;

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TEntryFilter>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoUnit);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoUnitAggregated; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoUnitAggregated; const aMode: TUIToEntryMode;
      const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);
    function GetProgressIndicator: IProgressIndicator;

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);

    function GetMemberOfUI: IMemberOfUI;

    procedure LoadUnitKindCombobox;
    procedure SetEnableCheckboxesCaption;
  public
    constructor Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator); reintroduce;
    destructor Destroy; override;
    property MemberOfUI: IMemberOfUI read GetMemberOfUI;
    property CurrentUnitId: UInt32 read fCurrentUnitId;
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, StringTools, MessageDialogs, Vdm.Globals, VclUITools, Helper.ConstraintControls,
  Helper.Frame;

{ TfraUnit }

constructor TfraUnit.Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator);
begin
  inherited Create(AOwner);
  fProgressIndicator := aProgressIndicator;
  fUnitMemberOf := TfraMemberOf.Create(Self);
  fUnitMemberOf.Parent := pnMemberOf;
  fUnitMemberOf.Align := TAlign.alClient;

  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edUnitName);
  fComponentValueChangedObserver.RegisterCheckbox(cbUnitActive);
  fComponentValueChangedObserver.RegisterCombobox(cbUnitKind);
  fComponentValueChangedObserver.RegisterChangeableText(deUnitActiveSince);
  fComponentValueChangedObserver.RegisterChangeableText(deUnitActiveUntil);
  fComponentValueChangedObserver.RegisterChangeableText(deDataConfirmedOn);

  fValidatableValueControlsRegistry := TValidatableValueControlsRegistry.Create;
  fValidatableValueControlsRegistry.RegisterControl(deUnitActiveSince);
  fValidatableValueControlsRegistry.RegisterControl(deUnitActiveUntil);
  fValidatableValueControlsRegistry.RegisterControl(deDataConfirmedOn);

  fExtendedListview := TExtendedListview<TDtoUnit, UInt32>.Create(lvListview,
    procedure(const aData: TDtoUnit; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.ToString;
    end,
    function(const aData: TDtoUnit): UInt32
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
        acStartNewEntry.Execute;
      end;
    end,
    200
  );

  lbVersionInfo.Caption := '';
  LoadUnitKindCombobox;
  SetEnableCheckboxesCaption;
end;

destructor TfraUnit.Destroy;
begin
  fDelayedLoadEntry.Free;
  fExtendedListview.Free;
  fComponentValueChangedObserver.Free;
  fValidatableValueControlsRegistry.Free;
  inherited;
end;

procedure TfraUnit.edFilterChange(Sender: TObject);
begin
  const lEmptyFilter = Length(edFilter.Text) = 0;
  fExtendedListview.Filter<string>(LowerCase(edFilter.Text),
    function(const aFilterExpression: string; const aData: TDtoUnit): Boolean
    begin
      Result := lEmptyFilter or (Pos(aFilterExpression, LowerCase(aData.ToString)) > 0);
    end
  );
end;

procedure TfraUnit.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  fUnitMemberOf.SetActionsEnabled(True);
  SetEditMode(False);
end;

procedure TfraUnit.acSaveCurrentEntryExecute(Sender: TObject);
begin
  if not fValidatableValueControlsRegistry.ValidateValues then
    Exit;

  var lResponse := fBusinessIntf.SaveCurrentEntry;
  if lResponse.Status = TCrudSaveStatus.Successful then
  begin
    fUnitMemberOf.SetActionsEnabled(True);
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
  fUnitMemberOf.SetActionsEnabled(False);
  StartEdit;
end;

procedure TfraUnit.BeginWork;
begin
  fValidatableValueControlsRegistry.Form := Self.GetForm;
  fValidatableValueControlsRegistry.CancelControl := btReload;
  Show;
  var lWorkSection: IWorkSection;
  Supports(fUnitMemberOf, IWorkSection, lWorkSection);
  lWorkSection.BeginWork;
end;

procedure TfraUnit.cbEnableCheckboxesClick(Sender: TObject);
begin
  fExtendedListview.ClearCheckedIds;
  lvListview.Checkboxes := not lvListview.Checkboxes;
  SetEnableCheckboxesCaption;
end;

procedure TfraUnit.SetEnableCheckboxesCaption;
begin
  if lvListview.Checkboxes then
    cbEnableCheckboxes.Caption := 'Auswahlmodus deaktivieren'
  else
    cbEnableCheckboxes.Caption := 'Auswahlmodus aktivieren';
end;

procedure TfraUnit.cbShowInactiveUnitsClick(Sender: TObject);
begin
  var lListFilter := fBusinessIntf.ListFilter;
  lListFilter.ShowInactiveEntries := cbShowInactiveUnits.Checked;
  fBusinessIntf.ListFilter := lListFilter;
end;

procedure TfraUnit.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edUnitName.Text := '';
  cbUnitActive.Checked := True;
  cbUnitKind.ItemIndex := 0;
  deUnitActiveSince.Clear;
  deUnitActiveUntil.Clear;
  deDataConfirmedOn.Clear;
  fComponentValueChangedObserver.EndUpdate;
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

function TfraUnit.GetEntryFromUI(var aEntry: TDtoUnitAggregated; const aMode: TUIToEntryMode;
  const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
begin
  if TStringTools.IsEmpty(edUnitName.Text) then
  begin
    edUnitName.SetFocus;
    aProgressUISuspendScope.Suspend;
    TMessageDialogs.Ok('Die Bezeichnung muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Name := edUnitName.Text;
  aEntry.Active := cbUnitActive.Checked;
  aEntry.Kind := TUnitKind(cbUnitKind.ItemIndex);

  deUnitActiveSince.Value.ToNullableDate(aEntry.ActiveSince);
  deUnitActiveUntil.Value.ToNullableDate(aEntry.ActiveUntil);
  deDataConfirmedOn.Value.ToNullableDate(aEntry.DataConfirmedOn);
end;

function TfraUnit.GetMemberOfUI: IMemberOfUI;
begin
  Result := fUnitMemberOf;
end;

function TfraUnit.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

procedure TfraUnit.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TEntryFilter>);
begin
  fBusinessIntf := aCommands;
  fUnitMemberOf.SetActionsEnabled(False);
end;

procedure TfraUnit.LoadCurrentEntry(const aEntryId: UInt32);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  fUnitMemberOf.SetActionsEnabled(True);
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

procedure TfraUnit.EndWork;
begin
  var lWorkSection: IWorkSection;
  Supports(fUnitMemberOf, IWorkSection, lWorkSection);
  lWorkSection.EndWork;
  Hide;
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
    if lRecordFound then
      fCurrentUnitId := lRecord.Id;
  end;
  fDelayedLoadEntry.SetData(TDelayedLoadEntryData.Create(lRecord.Id, lRecordFound, aDoStartEdit));
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
  cbUnitKind.ItemIndex := Ord(aEntry.Kind);
  deUnitActiveSince.Value.FromNullableDate(aEntry.ActiveSince);
  deUnitActiveUntil.Value.FromNullableDate(aEntry.ActiveUntil);
  deDataConfirmedOn.Value.FromNullableDate(aEntry.DataConfirmedOn);

  fExtendedListview.UpdateData(aEntry.&Unit);

  fComponentValueChangedObserver.EndUpdate;
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

procedure TfraUnit.LoadUnitKindCombobox;
begin
  try
    cbUnitKind.Items.BeginUpdate;
    for var i := Low(TUnitKind) to High(TUnitKind)  do
    begin
      cbUnitKind.Items.Add(UnitKindToStr(i));
    end;
  finally
    cbUnitKind.Items.EndUpdate;
  end;
end;

end.
