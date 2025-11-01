unit unPerson;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoPerson, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  PersonBusinessIntf, PersonAggregatedUI, DtoPersonAggregated, ComponentValueChangedObserver,
  unMemberOf, MemberOfUI,
  Vdm.Types, Vdm.Versioning.Types, CrudUI, VersionInfoEntryUI, DtoPersonNameId, ProgressIndicatorIntf, WorkSection,
  ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, ConstraintControls.IntegerEdit,
  ValidatableValueControlsRegistry;

type
  TfraPerson = class(TFrame, IPersonAggregatedUI, IVersionInfoEntryUI, IWorkSection)
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
    lbPersonBirthday: TLabel;
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
    lbMembershipnumber: TLabel;
    lbMembershipBegin: TLabel;
    lbMembershipEnd: TLabel;
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
    cbPersonOnBirthdaylist: TCheckBox;
    cbPersonExternal: TCheckBox;
    cbShowExternalPersons: TCheckBox;
    dePersonBirthday: TDateEdit;
    deMembershipBegin: TDateEdit;
    deMembershipEnd: TDateEdit;
    ieMembershipNumber: TIntegerEdit;
    edEMailaddress: TEdit;
    lbEMailaddress: TLabel;
    edPhonenumber: TEdit;
    lbPhonenumber: TLabel;
    cbPhonePriority: TCheckBox;
    procedure lvPersonListviewCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure lvPersonListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acPersonSaveCurrentRecordExecute(Sender: TObject);
    procedure acPersonReloadCurrentRecordExecute(Sender: TObject);
    procedure cbCheckboxFilterPersonsClick(Sender: TObject);
    procedure acPersonStartNewRecordExecute(Sender: TObject);
    procedure pcPersonDetailsChanging(Sender: TObject; var AllowChange: Boolean);
    procedure pcPersonDetailsChange(Sender: TObject);
    procedure edFilterChange(Sender: TObject);
    procedure lvPersonListviewDblClick(Sender: TObject);
    procedure cbPersonAddressChange(Sender: TObject);
    procedure cbPersonAddressSelect(Sender: TObject);
    procedure dePersonBirthdayChange(Sender: TObject);
    procedure deMembershipEndValueChanged(Sender: TObject);
    procedure edEMailaddressExit(Sender: TObject);
    procedure edPhonenumberExit(Sender: TObject);
  strict private
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: IPersonBusinessIntf;
    fExtendedListview: TExtendedListview<TDtoPerson, UInt32>;
    fPersonMemberOf: TfraMemberOf;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fProgressIndicator: IProgressIndicator;
    fValidatableValueControlsRegistry: TValidatableValueControlsRegistry;

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

    procedure BeginWork;
    procedure EndWork;

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
    function GetEntryFromUI(var aRecord: TDtoPersonAggregated; const aMode: TUIToEntryMode;
      const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
    procedure LoadCurrentEntry(const aPersonId: UInt32);
    function SetSelectedEntry(const aPersonId: UInt32): Boolean;
    function GetProgressIndicator: IProgressIndicator;

    procedure ExtentedListviewEndUpdate(Sender: TObject; const aTotalItemCount, aVisibleItemCount: Integer);
    function GetCurrentUnitId: UInt32;
  public
    constructor Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator); reintroduce;
    destructor Destroy; override;
    property CurrentUnitId: UInt32 read GetCurrentUnitId;
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, KeyIndexStrings, StringTools, MessageDialogs, Vdm.Globals, VclUITools,
  Helper.ConstraintControls, Helper.Frame, PatternValidation;

{ TfraPerson }

constructor TfraPerson.Create(AOwner: TComponent; const aProgressIndicator: IProgressIndicator);
begin
  inherited Create(AOwner);
  fProgressIndicator := aProgressIndicator;
  fPersonMemberOf := TfraMemberOf.Create(Self);
  fPersonMemberOf.Parent := tsMemberOf;
  fPersonMemberOf.Align := TAlign.alClient;

  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edPersonFirstname);
  fComponentValueChangedObserver.RegisterEdit(edPersonPraeposition);
  fComponentValueChangedObserver.RegisterEdit(edPersonLastname);
  fComponentValueChangedObserver.RegisterChangeableText(dePersonBirthday);
  fComponentValueChangedObserver.RegisterCheckbox(cbPersonActive);
  fComponentValueChangedObserver.RegisterCheckbox(cbPersonExternal);
  fComponentValueChangedObserver.RegisterCheckbox(cbPersonOnBirthdaylist);
  fComponentValueChangedObserver.RegisterCombobox(cbPersonAddress);
  fComponentValueChangedObserver.RegisterEdit(edNewAddressPostalcode);
  fComponentValueChangedObserver.RegisterEdit(edNewAddressCity);
  fComponentValueChangedObserver.RegisterEdit(edEMailaddress);
  fComponentValueChangedObserver.RegisterEdit(edPhonenumber);
  fComponentValueChangedObserver.RegisterCheckbox(cbPhonePriority);
  fComponentValueChangedObserver.RegisterCombobox(cbMembership);
  fComponentValueChangedObserver.RegisterChangeableText(ieMembershipNumber);
  fComponentValueChangedObserver.RegisterChangeableText(deMembershipBegin);
  fComponentValueChangedObserver.RegisterChangeableText(deMembershipEnd);
  fComponentValueChangedObserver.RegisterEdit(edMembershipEndText);
  fComponentValueChangedObserver.RegisterEdit(edMembershipEndReason);

  fValidatableValueControlsRegistry := TValidatableValueControlsRegistry.Create;
  fValidatableValueControlsRegistry.RegisterControl(dePersonBirthday);
  fValidatableValueControlsRegistry.RegisterControl(ieMembershipNumber);
  fValidatableValueControlsRegistry.RegisterControl(deMembershipBegin);
  fValidatableValueControlsRegistry.RegisterControl(deMembershipEnd);

  fExtendedListview := TExtendedListview<TDtoPerson, UInt32>.Create(lvPersonListview,
    procedure(const aData: TDtoPerson; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.ToString;
    end,
    function(const aData: TDtoPerson): UInt32
    begin
      Result := aData.NameId.Id;
    end,
    TComparer<UInt32>.Construct(
      function(const aLeft, aRight: UInt32): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft, aRight);
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
        acPersonStartNewRecord.Execute;
      end;
    end,
    200
  );
end;

destructor TfraPerson.Destroy;
begin
  fDelayedLoadEntry.Free;
  fExtendedListview.Free;
  fValidatableValueControlsRegistry.Free;
  fComponentValueChangedObserver.Free;
  inherited;
end;

procedure TfraPerson.edEMailaddressExit(Sender: TObject);
begin
  var lEmailAddr := edEMailaddress.Text;
  if (Length(lEmailAddr) > 0) and not TPatternValidation.IsEmailAddressValid(lEmailAddr) then
    edEMailaddress.Text := '';
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

procedure TfraPerson.edPhonenumberExit(Sender: TObject);
begin
  var lPhoneNmbr := edPhonenumber.Text;
  if (Length(lPhoneNmbr) > 0) and not TPatternValidation.IsPhoneNumberValid(lPhoneNmbr) then
    edPhonenumber.Text := '';
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
  if not fValidatableValueControlsRegistry.ValidateValues then
    Exit;

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

procedure TfraPerson.BeginWork;
begin
  fValidatableValueControlsRegistry.Form := Self.GetForm;
  fValidatableValueControlsRegistry.CancelControl := btPersonReload;
  Show;
  var lWorkSection: IWorkSection;
  Supports(fPersonMemberOf, IWorkSection, lWorkSection);
  lWorkSection.BeginWork;
end;

procedure TfraPerson.cbPersonAddressChange(Sender: TObject);
begin
  ConfigControlsForNewAddress;
end;

procedure TfraPerson.cbPersonAddressSelect(Sender: TObject);
begin
  ConfigControlsForNewAddress;
end;

procedure TfraPerson.cbCheckboxFilterPersonsClick(Sender: TObject);
begin
  edFilter.Text := '';
  var lListFilter := fBusinessIntf.ListFilter;
  lListFilter.IncludeInactive := cbShowInactivePersons.Checked;
  lListFilter.IncludeExternal := cbShowExternalPersons.Checked;
  fBusinessIntf.ListFilter := lListFilter;
end;

procedure TfraPerson.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  var lAddressStringsMapping := fBusinessIntf.AvailableAddresses.Data.GetActiveEntries;
  try
    cbPersonAddress.Items.Assign(lAddressStringsMapping.Strings);
    TVclUITools.SetComboboxItemIndex(cbPersonAddress,
      lAddressStringsMapping.Mapper.GetIndex(0));
  finally
    lAddressStringsMapping.Free;
  end;

  edPersonFirstname.Text := '';
  edPersonPraeposition.Text := '';
  edPersonLastname.Text := '';
  dePersonBirthday.Clear;

  cbPersonActive.Checked := True;
  cbPersonExternal.Checked := False;
  cbPersonOnBirthdaylist.Checked := False;
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  ConfigControlsForNewAddress;

  edEMailaddress.Text := '';
  edPhonenumber.Text := '';
  cbPhonePriority.Checked := False;

  cbMembership.ItemIndex := 0;
  ieMembershipNumber.Clear;

  deMembershipBegin.Clear;
  deMembershipEnd.Clear;
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
  Result := aPersonName.Firstname;
  if Length(Result) = 0 then
    Result := aPersonName.Lastname;
end;

function TfraPerson.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

function TfraPerson.GetCurrentUnitId: UInt32;
begin
  Result := fPersonMemberOf.CurrentUnitId;
end;

function TfraPerson.GetEntryFromUI(var aRecord: TDtoPersonAggregated; const aMode: TUIToEntryMode;
  const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
begin
  if TStringTools.IsEmpty(edPersonFirstname.Text) and TStringTools.IsEmpty(edPersonLastname.Text) then
  begin
    edPersonFirstname.SetFocus;
    aProgressUISuspendScope.Suspend;
    TMessageDialogs.Ok('Vorname oder Nachname müssen angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;
  if (cbMembership.ItemIndex > 0) and TStringTools.IsEmpty(ieMembershipNumber.Text) then
  begin
    ieMembershipNumber.SetFocus;
    aProgressUISuspendScope.Suspend;
    TMessageDialogs.Ok('Die Mitgliedsnummer muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;


  Result := True;
  aRecord.Firstname := edPersonFirstname.Text;
  aRecord.NameAddition := edPersonPraeposition.Text;
  aRecord.Lastname := edPersonLastname.Text;
  dePersonBirthday.Value.ToNullableSimpleDate(aRecord.Birthday);
  aRecord.Active := cbPersonActive.Checked;
  aRecord.External := cbPersonExternal.Checked;
  aRecord.OnBirthdayList := cbPersonOnBirthdaylist.Checked;

  aRecord.Emailaddress := edEMailaddress.Text;
  aRecord.Phonenumber := edPhonenumber.Text;
  aRecord.PhonePriority := cbPhonePriority.Checked;

  var lAddressStringsMapping: TKeyIndexStringsData := nil;
  try
    if aMode = TUIToEntryMode.OnNewEntry then
    begin
      lAddressStringsMapping := fBusinessIntf.AvailableAddresses.Data.GetActiveEntries;
    end
    else
    begin
      lAddressStringsMapping := fBusinessIntf.AvailableAddresses.Data.GetAllEntries;
    end;
    aRecord.AddressId := lAddressStringsMapping.Mapper.GetKey(cbPersonAddress.ItemIndex);
  finally
    lAddressStringsMapping.Free;
  end;

  aRecord.CreateNewAddress := False;
  if NewAddressRequested then
  begin
    if Length(edNewAddressCity.Text) = 0 then
    begin
      edNewAddressCity.SetFocus;
      aProgressUISuspendScope.Suspend;
      TMessageDialogs.Ok('Neue Adresse: Der Ortsname muss angegeben sein.', TMsgDlgType.mtInformation);
      Exit(False);
    end;
    aRecord.CreateNewAddress := True;
    aRecord.NewAddressStreet := cbPersonAddress.Text;
    aRecord.NewAddressPostalcode := edNewAddressPostalcode.Text;
    aRecord.NewAddressCity := edNewAddressCity.Text;
    var lNewAddessTitle := aRecord.NewAddressStreet +
      ', ' + aRecord.NewAddressPostalcode +
      ' ' + aRecord.NewAddressCity;
    aProgressUISuspendScope.Suspend;
    if TMessageDialogs.YesNo('Neue Adresse "' + lNewAddessTitle + '" anlegen und "' + GetPersonFirstname(aRecord.Person.NameId) +
      '" zuordnen?', TMsgDlgType.mtConfirmation) <> mrYes then
      Exit(False);
  end;

  aRecord.MembershipNoMembership := cbMembership.ItemIndex <= 0;
  aRecord.MembershipActive := cbMembership.ItemIndex = 1;
  aRecord.MembershipNumber := ieMembershipNumber.Value.Value;
  deMembershipBegin.Value.ToNullableDate(aRecord.MembershipBeginDate);
  deMembershipEnd.Value.ToNullableDate(aRecord.MembershipEndDate);
  if not deMembershipEnd.Value.Null then
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

function TfraPerson.SetSelectedEntry(const aPersonId: UInt32): Boolean;
begin
  Result := False;
  var lPerson := default(TDtoPerson);
  lPerson.NameId.Id := aPersonId;
  var lListItem: TListItem;
  if fExtendedListview.TryGetListItem(lPerson, lListItem) then
  begin
    lListItem.Selected := True;
    lListItem.MakeVisible(False);
    Result := True;
  end;
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
    if not lPerson.Active then
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

procedure TfraPerson.EndWork;
begin
  var lWorkSection: IWorkSection;
  Supports(fPersonMemberOf, IWorkSection, lWorkSection);
  lWorkSection.EndWork;
  Hide;
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

procedure TfraPerson.deMembershipEndValueChanged(Sender: TObject);
begin
  lbMembershipEndText.Enabled := not deMembershipEnd.Value.Null;
  edMembershipEndText.Enabled := lbMembershipEndText.Enabled;
end;

procedure TfraPerson.dePersonBirthdayChange(Sender: TObject);
begin
  if dePersonBirthday.Value.Null then
  begin
    cbPersonOnBirthdaylist.Enabled := False;
    cbPersonOnBirthdaylist.Checked := False;
  end
  else
  begin
    cbPersonOnBirthdaylist.Enabled := True;
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

  var lAddressStringsMapping := fBusinessIntf.AvailableAddresses.Data.GetAllEntries;
  try
    cbPersonAddress.Items.Assign(lAddressStringsMapping.Strings);
    TVclUITools.SetComboboxItemIndex(cbPersonAddress,
      lAddressStringsMapping.Mapper.GetIndex(aRecord.AddressId));
  finally
    lAddressStringsMapping.Free;
  end;

  edPersonFirstname.Text := aRecord.Firstname;
  edPersonPraeposition.Text := aRecord.NameAddition;
  edPersonLastname.Text := aRecord.Lastname;
  dePersonBirthday.Value.FromNullableSimpleDate(aRecord.Birthday);

  fExtendedListview.UpdateData(aRecord.Person);

  cbPersonActive.Checked := aRecord.Active;
  cbPersonExternal.Checked := aRecord.External;
  cbPersonOnBirthdaylist.Checked := aRecord.OnBirthdayList;
  edNewAddressPostalcode.Text := '';
  edNewAddressCity.Text := '';
  ConfigControlsForNewAddress;

  edEMailaddress.Text := aRecord.Emailaddress;
  edPhonenumber.Text := aRecord.Phonenumber;
  cbPhonePriority.Checked := aRecord.PhonePriority;

  if aRecord.MembershipId > 0 then
  begin
    if aRecord.MembershipActive then
      cbMembership.ItemIndex := 1
    else
      cbMembership.ItemIndex := 2;
    ieMembershipNumber.Value.Value := aRecord.MembershipNumber;

    deMembershipBegin.Value.FromNullableDate(aRecord.MembershipBeginDate);
    deMembershipEnd.Value.FromNullableDate(aRecord.MembershipEndDate);

    edMembershipEndText.Text := aRecord.MembershipEndDateText;
    edMembershipEndReason.Text := aRecord.MembershipEndReason;
  end
  else
  begin
    cbMembership.ItemIndex := 0;
    ieMembershipNumber.Clear;
    deMembershipBegin.Clear;
    deMembershipEnd.Clear;
    edMembershipEndText.Text := '';
    edMembershipEndReason.Text := '';
  end;

  fComponentValueChangedObserver.EndUpdate;

  tsMemberOf.Caption := GetPersonFirstname(aRecord.Person.NameId) + ' ist &Teil von ...';
end;

end.
