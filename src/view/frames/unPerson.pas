unit unPerson;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoPerson, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  PersonBusinessIntf, PersonAggregatedUI, DtoPersonAggregated, ComponentValueChangedObserver,
  unMemberOf, MemberOfUI, CheckboxDatetimePickerHandler,
  Vdm.Types, Vdm.Versioning.Types, CrudUI, VersionInfoEntryUI, DtoPersonNameId, ProgressIndicatorIntf;

type
  TfraPerson = class(TFrame, IPersonAggregatedUI, IVersionInfoEntryUI)
    pnPersonListview: TPanel;
    Splitter1: TSplitter;
    pnPersonDetails: TPanel;
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
    alActionList: TActionList;
    acPersonSaveCurrentRecord: TAction;
    acPersonReloadCurrentRecord: TAction;
    btPersonSave: TButton;
    btPersonReload: TButton;
    cbPersonActive: TCheckBox;
    cbPersonAddress: TComboBox;
    lbPersonAdress: TLabel;
    lbNewAddressPostalcodeCity: TLabel;
    edNewAddressPostalcode: TEdit;
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
    lbListviewItemCount: TLabel;
    lbBasedataVersionInfo: TLabel;
    edFilter: TEdit;
    lbFilter: TLabel;
    pnTop: TPanel;
    lbTitle: TLabel;
    procedure lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acPersonSaveCurrentRecordExecute(Sender: TObject);
    procedure acPersonReloadCurrentRecordExecute(Sender: TObject);
    procedure cbShowInactivePersonsClick(Sender: TObject);
    procedure cbMembershipEndKnownClick(Sender: TObject);
    procedure acPersonStartNewRecordExecute(Sender: TObject);
    procedure pcPersonDetailsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure pcPersonDetailsChange(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure lvPersonListviewDblClick(Sender: TObject);
    procedure cbPersonAddressChange(Sender: TObject);
    procedure cbPersonAddressSelect(Sender: TObject);
  strict private
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: IPersonBusinessIntf;
    fExtendedListview: TExtendedListview<TDtoPerson>;
    fPersonMemberOf: TfraMemberOf;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fPersonBirthdayHandler: TCheckboxDatetimePickerHandler;
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;
    fProgressIndicator: IProgressIndicator;

    procedure CMVisiblechanged(var Message: TMessage); message CM_VISIBLECHANGED;
    function NewAddressRequested: Boolean;
    procedure ConfigControlsForNewAddress;
    function GetPersonFirstname(const aPersonName: TDtoPersonNameId): string;

    function GetMemberOfUI: IMemberOfUI;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure StartEdit;
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    procedure EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);

    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry; const aVersionInfoEntryIndex: UInt16);
    procedure ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
    procedure SetPersonBusinessIntf(const aCommands: IPersonBusinessIntf);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aRecord: TDtoPerson);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aPersonId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aRecord: TDtoPersonAggregated; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aRecord: TDtoPersonAggregated): Boolean;
    procedure LoadCurrentEntry(const aPersonId: UInt32);
    function GetProgressIndicator: IProgressIndicator;

    procedure ExtentedListviewEndUpdate(Sender: TObject; const aTotalItemCount, aVisibleItemCount: Integer);
  public
    constructor Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator); reintroduce;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, StringTools, MessageDialogs, Vdm.Globals, VclUITools;

{ TfraPerson }

constructor TfraPerson.Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator);
begin
  inherited Create(AOwner);
  fProgressIndicator := aProgressIndicator;
  fPersonMemberOf := TfraMemberOf.Create(Self);
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

  fExtendedListview := TExtendedListview<TDtoPerson>.Create(lvPersonListview,
    procedure(const aData: TDtoPerson; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.ToString;
    end,
    TComparer<TDtoPerson>.Construct(
      function(const aLeft, aRight: TDtoPerson): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.NameId.Id, aRight.NameId.Id);
      end
    )
  );
  fExtendedListview.OnEndUpdate := ExtentedListviewEndUpdate;

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

destructor TfraPerson.Destroy;
begin
  fDelayedLoadEntry.Free;
  fExtendedListview.Free;
  fComponentValueChangedObserver.Free;
  fActiveUntilHandler.Free;
  fActiveSinceHandler.Free;
  fPersonBirthdayHandler.Free;
  inherited;
end;

procedure TfraPerson.edFilterChange(Sender: TObject);
begin
  const lEmptyFilter = Length(edFilter.Text) = 0;
  fExtendedListview.Filter<string>(LowerCase(edFilter.Text),
    function(const aFilterExpression: string; const aData: TDtoPerson): Boolean
    begin
      Result := lEmptyFilter or (Pos(aFilterExpression, LowerCase(aData.ToString)) > 0);
    end
  );
end;

procedure TfraPerson.ExtentedListviewEndUpdate(Sender: TObject; const aTotalItemCount, aVisibleItemCount: Integer);
begin
  if aTotalItemCount > aVisibleItemCount then
    lbListviewItemCount.Caption := IntToStr(aVisibleItemCount) + ' gefiltert aus ' + IntToStr(aTotalItemCount) + ' Datensätzen'
  else
    lbListviewItemCount.Caption := IntToStr(aVisibleItemCount) + ' Datensätze';
end;

procedure TfraPerson.acPersonReloadCurrentRecordExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfraPerson.acPersonSaveCurrentRecordExecute(Sender: TObject);
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

procedure TfraPerson.acPersonStartNewRecordExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  StartEdit;
end;

procedure TfraPerson.cbMembershipEndKnownClick(Sender: TObject);
begin
  lbMembershipEndText.Enabled := not dtMembershipEnd.Enabled;
  edMembershipEndText.Enabled := not dtMembershipEnd.Enabled;
end;

procedure TfraPerson.cbPersonAddressChange(Sender: TObject);
begin
  ConfigControlsForNewAddress;
end;

procedure TfraPerson.cbPersonAddressSelect(Sender: TObject);
begin
  ConfigControlsForNewAddress;
end;

procedure TfraPerson.cbShowInactivePersonsClick(Sender: TObject);
begin
  edFilter.Text := '';
  fBusinessIntf.ShowInactivePersons := cbShowInactivePersons.Checked;
end;

procedure TfraPerson.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;
  cbPersonAddress.Items.Assign(fBusinessIntf.AvailableAddresses.Data.Strings);
  TVclUITools.SetComboboxItemIndex(cbPersonAddress, -1);

  edPersonFirstname.Text := '';
  edPersonPraeposition.Text := '';
  edPersonLastname.Text := '';
  fPersonBirthdayHandler.Clear;

  cbPersonActive.Checked := True;
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  ConfigControlsForNewAddress;

  cbMembership.ItemIndex := 0;
  edMembershipNumber.Text := '';

  fActiveSinceHandler.Clear;
  fActiveUntilHandler.Clear;
  edMembershipEndText.Text := '';

  fComponentValueChangedObserver.EndUpdate;
  tsMemberOf.Caption := '??? ist Teil von ...';
end;

procedure TfraPerson.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfraPerson.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfraPerson.DeleteEntryFromUI(const aPersonId: UInt32);
begin

end;

function TfraPerson.GetMemberOfUI: IMemberOfUI;
begin
  Result := fPersonMemberOf;
end;

function TfraPerson.GetPersonFirstname(const aPersonName: TDtoPersonNameId): string;
begin
  Result := aPersonName.Vorname;
  if Length(Result) = 0 then
    Result := aPersonName.Nachname;
end;

function TfraPerson.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

function TfraPerson.GetEntryFromUI(var aRecord: TDtoPersonAggregated): Boolean;
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
  aRecord.Birthday := fPersonBirthdayHandler.Datetime;
  aRecord.Active := cbPersonActive.Checked;
  aRecord.AddressIndex := cbPersonAddress.ItemIndex;

  aRecord.CreateNewAddress := False;
  if NewAddressRequested then
  begin
    aRecord.CreateNewAddress := True;
    aRecord.NewAddressStreet := cbPersonAddress.Text;
    aRecord.NewAddressPostalcode := edNewAddressPostalcode.Text;
    aRecord.NewAddressCity := edNewAddressCity.Text;
    var lNewAddessTitle := aRecord.NewAddressStreet +
      ', ' + aRecord.NewAddressPostalcode +
      ' ' + aRecord.NewAddressCity;
    if TMessageDialogs.YesNo('Neue Adresse "' + lNewAddessTitle + '" anlegen und ' + GetPersonFirstname(aRecord.Person.NameId) +
      ' zuordnen?', TMsgDlgType.mtConfirmation) <> mrYes then
      Exit(False);
  end;

  aRecord.MembershipNoMembership := cbMembership.ItemIndex <= 0;
  aRecord.MembershipActive := cbMembership.ItemIndex = 1;
  aRecord.MembershipNumber := StrToIntDef(edMembershipNumber.Text, 0);
  aRecord.MembershipBeginDate := fActiveSinceHandler.Datetime;
  aRecord.MembershipEndDate := fActiveUntilHandler.Datetime;
  if cbMembershipEndKnown.Checked then
  begin
    aRecord.MembershipEndDateText := '';
  end
  else
  begin
    aRecord.MembershipEndDateText := edMembershipEndText.Text;
  end;
  aRecord.MembershipEndReason := edMembershipEndReason.Text;
end;

procedure TfraPerson.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
begin

end;

procedure TfraPerson.SetPersonBusinessIntf(const aCommands: IPersonBusinessIntf);
begin
  pcPersonDetails.ActivePage := tsPersonaldata;
  fPersonMemberOf.SetActionsEnabled(False);
  fBusinessIntf := aCommands;
end;

procedure TfraPerson.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbBasedataVersionInfo, aVersionInfoEntry);
end;

procedure TfraPerson.StartEdit;
begin
  pcPersonDetails.ActivePage := tsPersonaldata;
  edPersonFirstname.SetFocus;
  SetEditMode(True);
end;

procedure TfraPerson.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbBasedataVersionInfo, nil);
end;

procedure TfraPerson.CMVisiblechanged(var Message: TMessage);
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

procedure TfraPerson.LoadCurrentEntry(const aPersonId: UInt32);
begin
  fBusinessIntf.LoadPerson(aPersonId, (pcPersonDetails.ActivePage = tsMemberOf));
  SetEditMode(False);
end;

procedure TfraPerson.ListEnumBegin;
begin
  fExtendedListview.BeginUpdate;
  fExtendedListview.Clear;
end;

procedure TfraPerson.ListEnumProcessItem(const aRecord: TDtoPerson);
begin
  fExtendedListview.Add(aRecord);
end;

procedure TfraPerson.ListEnumEnd;
begin
  if lvPersonListview.Items.Count > 0 then
  begin
    lvPersonListview.Items[0].Selected := True;
  end;
  fExtendedListview.EndUpdate;
  lvPersonListview.SetFocus;
end;

procedure TfraPerson.lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := true;
  var lPerson: TDtoPerson;
  if fExtendedListview.TryGetListItemData(Item, lPerson) then
  begin
    if not lPerson.Aktiv then
      Sender.Canvas.Font.Color := TVdmGlobals.GetInactiveColor;
  end;
end;

procedure TfraPerson.lvPersonListviewDblClick(Sender: TObject);
begin
  if not Assigned(lvPersonListview.Selected) then
    Exit;

  EnqueueLoadEntry(lvPersonListview.Selected, True);
end;

procedure TfraPerson.lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
    EnqueueLoadEntry(Item, False)
  else
    EnqueueLoadEntry(nil, False);
end;

function TfraPerson.NewAddressRequested: Boolean;
begin
  Result := (Length(cbPersonAddress.Text) > 0) and (cbPersonAddress.ItemIndex < 0);
end;

procedure TfraPerson.ConfigControlsForNewAddress;
begin
  var lNewEnabled := NewAddressRequested;
  if edNewAddressPostalcode.Enabled and not lNewEnabled then
  begin
    edNewAddressPostalcode.Text := '';
    edNewAddressCity.Text := '';
  end;
  edNewAddressPostalcode.Enabled := lNewEnabled;
  lbNewAddressPostalcodeCity.Enabled := lNewEnabled;
  edNewAddressCity.Enabled := lNewEnabled;
end;

procedure TfraPerson.EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);
begin
  if fComponentValueChangedObserver.InUpdated then
    Exit;

  var lPersonFound := False;
  var lPerson: TDtoPerson;
  if Assigned(aListItem) then
  begin
    lPersonFound := fExtendedListview.TryGetListItemData(aListItem, lPerson);
  end;

  fDelayedLoadEntry.SetData(TDelayedLoadEntryData.Create(lPerson.NameId.Id, lPersonFound, aDoStartEdit));
end;

procedure TfraPerson.pcPersonDetailsChange(Sender: TObject);
begin
  fPersonMemberOf.SetActionsEnabled(pcPersonDetails.ActivePage = tsMemberOf);
  if pcPersonDetails.ActivePage = tsMemberOf then
  begin
    fBusinessIntf.LoadPersonsMemberOfs;
  end;
end;

procedure TfraPerson.pcPersonDetailsChanging(Sender: TObject; var AllowChange: Boolean);
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

procedure TfraPerson.SetEditMode(const aEditMode: Boolean);
begin
  var lInEditModeBefore := fInEditMode;
  fInEditMode := aEditMode;
  acPersonSaveCurrentRecord.Enabled := fInEditMode;
  acPersonReloadCurrentRecord.Enabled := fInEditMode;
  if lInEditModeBefore and not fInEditMode then
    lvPersonListview.SetFocus;
end;

procedure TfraPerson.SetEntryToUI(const aRecord: TDtoPersonAggregated; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;
  cbPersonAddress.Items.Assign(fBusinessIntf.AvailableAddresses.Data.Strings);

  edPersonFirstname.Text := aRecord.Firstname;
  edPersonPraeposition.Text := aRecord.Praeposition;
  edPersonLastname.Text := aRecord.Lastname;
  fPersonBirthdayHandler.Datetime := aRecord.Birthday;

  fExtendedListview.UpdateData(aRecord.Person);

  cbPersonActive.Checked := aRecord.Active;
  TVclUITools.SetComboboxItemIndex(cbPersonAddress, aRecord.AddressIndex);
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  ConfigControlsForNewAddress;

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

  tsMemberOf.Caption := GetPersonFirstname(aRecord.Person.NameId) + ' ist &Teil von ...';
end;

end.
