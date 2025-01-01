unit unPersonMemberOfsEditDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, DtoMemberAggregated,
  CheckboxDatetimePickerHandler;

type
  TfmPersonMemberOfsEditDlg = class(TForm)
    cbUnit: TComboBox;
    cbActive: TCheckBox;
    btSave: TButton;
    btReload: TButton;
    lbUnit: TLabel;
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
  private
    fActiveSinceHandler: TCheckboxDatetimePickerHandler;
    fActiveUntilHandler: TCheckboxDatetimePickerHandler;
  public
    procedure FillAvailableUnits(const aUnits: TStrings);
    procedure FillAvailableRoles(const aRoles: TStrings);
    function Execute(const aMemberRecord: TDtoMemberAggregated; const aNewRecord: Boolean): Boolean;
  end;

implementation

uses MessageDialogs, VclUITools;

{$R *.dfm}

{ TfmPersonMemberOfsEditDlg }

procedure TfmPersonMemberOfsEditDlg.btSaveClick(Sender: TObject);
begin
  if cbUnit.ItemIndex < 1 then
  begin
    TMessageDialogs.Ok('Bitte die Einheit auswählen.', TMsgDlgType.mtInformation);
    cbUnit.SetFocus;
    Exit;
  end;
  ModalResult := mrOk;
end;

function TfmPersonMemberOfsEditDlg.Execute(const aMemberRecord: TDtoMemberAggregated; const aNewRecord: Boolean): Boolean;
begin
  Result := False;
  cbUnit.Items.Assign(aMemberRecord.AvailableUnits.Data.Strings);
  cbRole.Items.Assign(aMemberRecord.AvailableRoles.Data.Strings);
  TVclUITools.SetComboboxItemIndex(cbUnit, aMemberRecord.UnitIndex);
  TVclUITools.SetComboboxItemIndex(cbRole, aMemberRecord.RoleIndex);
  cbActive.Checked := aMemberRecord.Member.Active;
  fActiveSinceHandler.Datetime := aMemberRecord.Member.ActiveSince;
  fActiveUntilHandler.Datetime := aMemberRecord.Member.ActiveUntil;
  if aNewRecord then
  begin
    Caption := 'Neue Verbindung hinzufügen';
  end
  else
  begin
    Caption := 'Verbindung bearbeiten';
  end;
  if ShowModal = mrOk then
  begin
    Result := True;
    aMemberRecord.UnitIndex := cbUnit.ItemIndex;
    aMemberRecord.RoleIndex := cbRole.ItemIndex;
    aMemberRecord.Active := cbActive.Checked;
    aMemberRecord.ActiveSince := fActiveSinceHandler.Datetime;
    aMemberRecord.ActiveUntil := fActiveUntilHandler.Datetime;
  end;
end;

procedure TfmPersonMemberOfsEditDlg.FillAvailableRoles(const aRoles: TStrings);
begin
  cbRole.Items.Assign(aRoles);
end;

procedure TfmPersonMemberOfsEditDlg.FillAvailableUnits(const aUnits: TStrings);
begin
  cbUnit.Items.Assign(aUnits);
end;

procedure TfmPersonMemberOfsEditDlg.FormCreate(Sender: TObject);
begin
  fActiveSinceHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipBeginKnown, dtMembershipBegin);
  fActiveUntilHandler := TCheckboxDatetimePickerHandler.Create(cbMembershipEndKnown, dtMembershipEnd);
end;

procedure TfmPersonMemberOfsEditDlg.FormDestroy(Sender: TObject);
begin
  fActiveSinceHandler.Free;
  fActiveUntilHandler.Free;
end;

end.
