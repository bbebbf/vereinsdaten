unit unMemberOfsEditDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, DtoMemberAggregated,
  Vdm.Types, ConstraintControls.ConstraintEdit, ConstraintControls.DateEdit, ValidatableValueControlsRegistry;

type
  TfmMemberOfsEditDlg = class(TForm)
    cbDetailItem: TComboBox;
    cbActive: TCheckBox;
    btSave: TButton;
    btReload: TButton;
    lbDetailItem: TLabel;
    cbRole: TComboBox;
    lbRole: TLabel;
    lbMembershipBegin: TLabel;
    lbMembershipEnd: TLabel;
    deMembershipBegin: TDateEdit;
    deMembershipEnd: TDateEdit;
    procedure btSaveClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
  strict private
    fDetailItemTitle: string;
    fValidatableValueControlsRegistry: TValidatableValueControlsRegistry;
  public
    function Execute(const aDetailItemTitle: string; const aMemberRecord: TDtoMemberAggregated;
      const aNewRecord: Boolean): Boolean;
  end;

implementation

uses KeyIndexStrings, MessageDialogs, VclUITools, Helper.ConstraintControls;

{$R *.dfm}

{ TfmPersonMemberOfsEditDlg }

procedure TfmMemberOfsEditDlg.btSaveClick(Sender: TObject);
begin
  if not fValidatableValueControlsRegistry.ValidateValues then
    Exit;

  if cbDetailItem.ItemIndex < 0 then
  begin
    TMessageDialogs.Ok('Bitte die ' + fDetailItemTitle + ' auswählen.', TMsgDlgType.mtInformation);
    cbDetailItem.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

function TfmMemberOfsEditDlg.Execute(const aDetailItemTitle: string;
  const aMemberRecord: TDtoMemberAggregated; const aNewRecord: Boolean): Boolean;
begin
  Result := False;
  fDetailItemTitle := aDetailItemTitle;
  lbDetailItem.Caption := fDetailItemTitle;

  var lDetailStringsMapping: TKeyIndexStringsData := nil;
  var lRoleStringsMapping: TKeyIndexStringsData := nil;
  try
    if aNewRecord then
    begin
      Caption := 'Neue Verbindung hinzufügen';
      lDetailStringsMapping := aMemberRecord.AvailableDetailItems.Data.GetActiveEntries;
      lRoleStringsMapping := aMemberRecord.AvailableRoles.Data.GetActiveEntries;
    end
    else
    begin
      Caption := 'Verbindung bearbeiten';
      lDetailStringsMapping := aMemberRecord.AvailableDetailItems.Data.GetAllEntries;
      lRoleStringsMapping := aMemberRecord.AvailableRoles.Data.GetAllEntries;
    end;
    ActiveControl := cbDetailItem;

    cbDetailItem.Items.Assign(lDetailStringsMapping.Strings);
    cbRole.Items.Assign(lRoleStringsMapping.Strings);
    TVclUITools.SetComboboxItemIndex(cbDetailItem, lDetailStringsMapping.Mapper.GetIndex(aMemberRecord.DetailItemId));
    TVclUITools.SetComboboxItemIndex(cbRole, lRoleStringsMapping.Mapper.GetIndex(aMemberRecord.RoleId));
    cbActive.Checked := aMemberRecord.Member.Active;
    deMembershipBegin.Value.FromNullableDate(aMemberRecord.Member.ActiveSince);
    deMembershipEnd.Value.FromNullableDate(aMemberRecord.Member.ActiveUntil);
    if ShowModal = mrOk then
    begin
      Result := True;
      aMemberRecord.DetailItemId := lDetailStringsMapping.Mapper.GetKey(cbDetailItem.ItemIndex);
      aMemberRecord.RoleId := lRoleStringsMapping.Mapper.GetKey(cbRole.ItemIndex);
      aMemberRecord.Active := cbActive.Checked;
      deMembershipBegin.Value.ToNullableDate(aMemberRecord.Member.ActiveSince);
      deMembershipEnd.Value.ToNullableDate(aMemberRecord.Member.ActiveUntil);
    end;
  finally
    lRoleStringsMapping.Free;
    lDetailStringsMapping.Free;
  end;
end;

procedure TfmMemberOfsEditDlg.FormCreate(Sender: TObject);
begin
  fValidatableValueControlsRegistry := TValidatableValueControlsRegistry.Create;
  fValidatableValueControlsRegistry.RegisterControl(deMembershipBegin);
  fValidatableValueControlsRegistry.RegisterControl(deMembershipEnd);
end;

procedure TfmMemberOfsEditDlg.FormDestroy(Sender: TObject);
begin
  fValidatableValueControlsRegistry.Free;
end;

procedure TfmMemberOfsEditDlg.FormShow(Sender: TObject);
begin
  fValidatableValueControlsRegistry.Form := Self;
  fValidatableValueControlsRegistry.CancelControl := btReload;
end;

end.
