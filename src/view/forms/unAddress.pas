unit unAddress;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoAddress, DtoAddressAggregated, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, DelayedExecute, Vdm.Types, Vdm.Versioning.Types, VersionInfoEntryUI;

type
  TfmAddress = class(TForm, ICrudUI<TDtoAddressAggregated, TDtoAddress, UInt32, TVoid>, IVersionInfoEntryUI)
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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TVoid>;
    fExtendedListview: TExtendedListview<TDtoAddress>;
    fExtendedListviewMemberOfs: TExtendedListview<TDtoAddressAggregatedPersonMemberOf>;
    fDelayedExecute: TDelayedExecute<TPair<Boolean, UInt32>>;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoAddress);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoAddressAggregated; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoAddressAggregated): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);

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

  fExtendedListview := TExtendedListview<TDtoAddress>.Create(lvListview,
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
    TComparer<TDtoAddress>.Construct(
      function(const aLeft, aRight: TDtoAddress): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.Id, aRight.Id);
      end
    )
  );
  fExtendedListviewMemberOfs := TExtendedListview<TDtoAddressAggregatedPersonMemberOf>.Create(lvMemberOf,
    procedure(const aData: TDtoAddressAggregatedPersonMemberOf; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.PersonNameId.ToString;
    end,
    TComparer<TDtoAddressAggregatedPersonMemberOf>.Construct(
      function(const aLeft, aRight: TDtoAddressAggregatedPersonMemberOf): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.PersonNameId.Id, aRight.PersonNameId.Id);
      end
    )
  );

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
  fExtendedListviewMemberOfs.Free;
  fExtendedListview.Free;
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

procedure TfmAddress.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if fComponentValueChangedObserver.InUpdated then
    Exit;

  var lEntryFound := False;
  var lEntry: TDtoAddress;
  if Selected then
  begin
    lEntryFound := fExtendedListview.TryGetListItemData(Item, lEntry);
  end;

  fDelayedExecute.SetData(TPair<Boolean, UInt32>.Create(lEntryFound, lEntry.Id));
end;

procedure TfmAddress.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
  acDeleteCurrentEntry.Enabled := not fInEditMode;
end;

procedure TfmAddress.SetEntryToUI(const aEntry: TDtoAddressAggregated; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edAddressStreet.Text := aEntry.Street;
  edAddressPostalcode.Text := aEntry.Postalcode;
  edAddressCity.Text := aEntry.City;
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

procedure TfmAddress.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry;
  const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, aVersionInfoEntry);
end;

procedure TfmAddress.ClearVersionInfoEntryFromUI(const aVersionInfoEntryIndex: UInt16);
begin
  TVclUITools.VersionInfoToLabel(lbVersionInfo, nil);
end;

end.
