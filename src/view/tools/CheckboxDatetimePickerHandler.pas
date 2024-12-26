unit CheckboxDatetimePickerHandler;

interface

uses System.Classes, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TCheckboxDatetimePickerHandler = class
  strict private
    fCheckbox: TCheckBox;
    fDatetimePicker: TDateTimePicker;
    fOwnCheckboxClick: TNotifyEvent;
    procedure CheckboxClick(Sender: TObject);
    function GetDatetime: TDateTime;
    procedure SetDatetime(const aValue: TDateTime);
  public
    constructor Create(const aCheckbox: TCheckBox; const aDatetimePicker: TDateTimePicker);
    procedure Clear;
    property Datetime: TDateTime read GetDatetime write SetDatetime;
  end;

implementation

uses Vdm.Globals;

{ TCheckboxDatetimePickerHandler }

constructor TCheckboxDatetimePickerHandler.Create(const aCheckbox: TCheckBox;
  const aDatetimePicker: TDateTimePicker);
begin
  fCheckbox := aCheckbox;
  fOwnCheckboxClick := fCheckbox.OnClick;
  fCheckbox.OnClick := CheckboxClick;
  fDatetimePicker := aDatetimePicker;
  if fDatetimePicker.MinDate < TVdmGlobals.GetDateTimePickerNullValue then
    fDatetimePicker.MinDate := TVdmGlobals.GetDateTimePickerNullValue;
end;

procedure TCheckboxDatetimePickerHandler.Clear;
begin
  fCheckbox.Checked := False;
  CheckboxClick(fCheckbox);
  fDatetimePicker.Date := TVdmGlobals.GetDateTimePickerNullValue;
end;

function TCheckboxDatetimePickerHandler.GetDatetime: TDateTime;
begin
  if fCheckbox.Checked then
    Result := fDatetimePicker.Date
  else
    Result := 0;
end;

procedure TCheckboxDatetimePickerHandler.SetDatetime(const aValue: TDateTime);
begin
  fCheckbox.Checked := (aValue > 0);
  CheckboxClick(fCheckbox);
  if aValue > 0 then
    fDatetimePicker.Date := aValue
  else
    fDatetimePicker.Date := TVdmGlobals.GetDateTimePickerNullValue;
end;

procedure TCheckboxDatetimePickerHandler.CheckboxClick(Sender: TObject);
begin
  if fCheckbox.Checked then
  begin
    fDatetimePicker.Enabled := True;
    fDatetimePicker.Format := '';
  end
  else
  begin
    fDatetimePicker.Enabled := False;
    fDatetimePicker.Format := ' ';
  end;
  if Assigned(fOwnCheckboxClick) then
    fOwnCheckboxClick(fCheckbox);
end;

end.
