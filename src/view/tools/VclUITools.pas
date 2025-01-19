unit VclUITools;

interface

uses Vcl.Controls, Vcl.StdCtrls, Vdm.Versioning.Types;

type
  TVclUITools = class
  public
    class procedure VersionInfoToLabel(const aLabel: TLabel; const aVersionInfoEntry: TVersionInfoEntry);
    class procedure SetComboboxItemIndex(const aCombobox: TComboBox; const aItemIndex: Integer);
    class procedure HideAndMoveHorizontal(const aControlToHide: TControl; const aControlsToMove: TArray<TControl>);
  end;

implementation

uses System.UITypes;

{ TVclUITools }

class procedure TVclUITools.HideAndMoveHorizontal(const aControlToHide: TControl;
  const aControlsToMove: TArray<TControl>);
begin
  aControlToHide.Visible := False;
  if Length(aControlsToMove) = 0 then
    Exit;

  var lDelta := aControlsToMove[0].Left - aControlToHide.Left;
  for var lControl in aControlsToMove do
    lControl.Left := lControl.Left - lDelta;
end;

class procedure TVclUITools.SetComboboxItemIndex(const aCombobox: TComboBox; const aItemIndex: Integer);
begin
  aCombobox.ItemIndex := aItemIndex;
  if (aCombobox.Style = TComboBoxStyle.csDropDown) and (aItemIndex = -1) then
    aCombobox.Text := '';
end;

class procedure TVclUITools.VersionInfoToLabel(const aLabel: TLabel; const aVersionInfoEntry: TVersionInfoEntry);
begin
  if not Assigned(aVersionInfoEntry) then
  begin
    aLabel.Font.Color := TColors.SysWindowText;
    aLabel.Font.Style := [];
    aLabel.Caption := '';
    Exit;
  end;

  if aVersionInfoEntry.State = TVersionInfoEntryState.ServerConflict then
  begin
    aLabel.Font.Color := TColors.Red;
    aLabel.Font.Style := [TFontStyle.fsBold];
    aLabel.Caption := 'Versionskonflikt: ' + aVersionInfoEntry.ToString;
  end
  else
  begin
    aLabel.Font.Color := TColors.SysWindowText;
    aLabel.Font.Style := [];
    aLabel.Caption := 'Version: ' + aVersionInfoEntry.ToString;
  end;
end;

end.
