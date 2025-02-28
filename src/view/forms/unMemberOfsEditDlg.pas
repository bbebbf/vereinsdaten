unit unMemberOfsEditDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, DtoMemberAggregated,
  CheckboxDatetimePickerHandler, Vdm.Types;

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
    cbMembershipBeginKnown: TCheckBox;
    dtMembershipBegin: TDateTimePicker;
    dtMembershipEnd: TDateTimePicker;
    cbMembershipEndKnown: TCheckBox;
    lbMembershipEnd: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btSaveClick(Sender: TObject);
  strict private
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;
    fDetailItemTitle: string;
  public
    function Execute(const aDetailItemTitle: string; const aMemberRecord: TDtoMemberAggregated;
      const aNewRecord: Boolean): Boolean;
  end;

implementation

uses KeyIndexStrings, MessageDialogs, VclUITools;

{$R *.dfm}

{ TfmPersonMemberOfsEditDlg }

procedure TfmMemberOfsEditDlg.btSaveClick(Sender: TObject);
begin
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
    fActiveSinceHandler.Datetime := aMemberRecord.Member.ActiveSince;
    fActiveUntilHandler.Datetime := aMemberRecord.Member.ActiveUntil;
    if ShowModal = mrOk then
    begin
      Result := True;
      aMemberRecord.DetailItemId := lDetailStringsMapping.Mapper.GetKey(cbDetailItem.ItemIndex);
      aMemberRecord.RoleId := lRoleStringsMapping.Mapper.GetKey(cbRole.ItemIndex);
      aMemberRecord.Active := cbActive.Checked;
      aMemberRecord.ActiveSince := fActiveSinceHandler.Datetime;
      aMemberRecord.ActiveUntil := fActiveUntilHandler.Datetime;
    end;
  finally
    lRoleStringsMapping.Free;
    lDetailStringsMapping.Free;
  end;
end;

procedure TfmMemberOfsEditDlg.FormCreate(Sender: TObject);
begin
  fActiveSinceHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipBeginKnown, dtMembershipBegin);
  fActiveUntilHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipEndKnown, dtMembershipEnd);
end;

procedure TfmMemberOfsEditDlg.FormDestroy(Sender: TObject);
begin
  fActiveSinceHandler.Free;
  fActiveUntilHandler.Free;
end;

end.
