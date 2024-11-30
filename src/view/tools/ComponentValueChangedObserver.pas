unit ComponentValueChangedObserver;

interface

uses System.Classes, System.Generics.Collections, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TComponentValueChangedControlEntry = class
  strict private
    fControl: TControl;
    fValueChanged: Boolean;
    fOriginalChangedNotifyEvent: TNotifyEvent;
    fNotifyRegisterChanged: TNotifyEvent;
    fNotifyRegisterUnchanged: TNotifyEvent;
  strict protected
    procedure NotifyValueChanged(const aValueChanged: Boolean);
  public
    constructor Create(const aControl: TControl;
      const aOriginalChangedNotifyEvent, aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; virtual;
  end;

  TComponentValueChangedEditEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TEdit;
    fOldValue: string;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TEdit; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedCheckboxEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TCheckbox;
    fOldValue: Boolean;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TCheckbox; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedComboboxEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TComboBox;
    fOldValue: Integer;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TComboBox; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedDateTimePickerEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TDateTimePicker;
    fOldValue: TDateTime;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TDateTimePicker; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedEvent = procedure(Sender, Control: TObject) of object;

  TComponentValueChangedObserver = class
  strict private
    fRegister: TObjectDictionary<TControl, TComponentValueChangedControlEntry>;
    fChangedControlCount: Integer;
    fInUpdate: Integer;
    fOnValuesChanged: TNotifyEvent;
    fOnValuesUnchanged: TNotifyEvent;
    fOnComponentValueChangedEvent: TComponentValueChangedEvent;
    fOnComponentValueUnchangedEvent: TComponentValueChangedEvent;
    procedure ControlChanged(Sender: TObject);
    procedure ControlUnChanged(Sender: TObject);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterEdit(const aEdit: TEdit);
    procedure RegisterCheckbox(const aCheckbox: TCheckBox);
    procedure RegisterCombobox(const aCombobox: TCombobox);
    procedure RegisterDateTimePicker(const aDateTimePicker: TDateTimePicker);
    procedure BeginUpdate;
    procedure EndUpdate;
    property OnValuesChanged: TNotifyEvent read fOnValuesChanged write fOnValuesChanged;
    property OnValuesUnchanged: TNotifyEvent read fOnValuesUnchanged write fOnValuesUnchanged;
    property OnComponentValueChangedEvent: TComponentValueChangedEvent read fOnComponentValueChangedEvent
      write fOnComponentValueChangedEvent;
    property OnComponentValueUnchangedEvent: TComponentValueChangedEvent read fOnComponentValueUnchangedEvent
      write fOnComponentValueUnchangedEvent;
  end;

implementation

{ TComponentValueChangedObserver }

constructor TComponentValueChangedObserver.Create;
begin
  inherited Create;
  fRegister := TObjectDictionary<TControl, TComponentValueChangedControlEntry>.Create([doOwnsValues]);
end;

destructor TComponentValueChangedObserver.Destroy;
begin
  fRegister.Free;
  inherited;
end;

procedure TComponentValueChangedObserver.BeginUpdate;
begin
  AtomicIncrement(fInUpdate);
end;

procedure TComponentValueChangedObserver.EndUpdate;
begin
  if AtomicDecrement(fInUpdate) > 0 then
    Exit;

  fChangedControlCount := 0;
  for var lEntry in fRegister.Values do
  begin
    lEntry.StoreOldValue;
  end;
end;

procedure TComponentValueChangedObserver.RegisterCheckbox(const aCheckbox: TCheckBox);
begin
  fRegister.AddOrSetValue(aCheckbox,
    TComponentValueChangedCheckboxEntry.Create(aCheckbox, ControlChanged, ControlUnChanged));
end;

procedure TComponentValueChangedObserver.RegisterCombobox(const aCombobox: TCombobox);
begin
  fRegister.AddOrSetValue(aCombobox,
    TComponentValueChangedComboboxEntry.Create(aCombobox, ControlChanged, ControlUnChanged));
end;

procedure TComponentValueChangedObserver.RegisterDateTimePicker(const aDateTimePicker: TDateTimePicker);
begin
  fRegister.AddOrSetValue(aDateTimePicker,
    TComponentValueChangedDateTimePickerEntry.Create(aDateTimePicker, ControlChanged, ControlUnChanged));
end;

procedure TComponentValueChangedObserver.RegisterEdit(const aEdit: TEdit);
begin
  fRegister.AddOrSetValue(aEdit,
    TComponentValueChangedEditEntry.Create(aEdit, ControlChanged, ControlUnChanged));
end;

procedure TComponentValueChangedObserver.ControlChanged(Sender: TObject);
begin
  if fInUpdate > 0 then
    Exit;

  if (AtomicIncrement(fChangedControlCount) = 1) and Assigned(fOnValuesChanged) then
    fOnValuesChanged(Self);
  if Assigned(fOnComponentValueChangedEvent) then
    fOnComponentValueChangedEvent(Self, Sender);
end;

procedure TComponentValueChangedObserver.ControlUnChanged(Sender: TObject);
begin
  if fInUpdate > 0 then
    Exit;

  if (AtomicDecrement(fChangedControlCount) = 0) and Assigned(fOnValuesUnchanged) then
    fOnValuesUnchanged(Self);
  if Assigned(fOnComponentValueUnchangedEvent) then
    fOnComponentValueUnchangedEvent(Self, Sender);
end;

{ TComponentValueChangedControlEntry }

constructor TComponentValueChangedControlEntry.Create(const aControl: TControl;
  const aOriginalChangedNotifyEvent, aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create;
  fControl := aControl;
  fOriginalChangedNotifyEvent := aOriginalChangedNotifyEvent;
  fNotifyRegisterChanged := aNotifyRegisterChanged;
  fNotifyRegisterUnchanged := aNotifyRegisterUnchanged;
end;

procedure TComponentValueChangedControlEntry.NotifyValueChanged(const aValueChanged: Boolean);
begin
  if Assigned(fOriginalChangedNotifyEvent) then
    fOriginalChangedNotifyEvent(fControl);

  if fValueChanged = aValueChanged then
    Exit;

  fValueChanged := aValueChanged;
  if fValueChanged then
    fNotifyRegisterChanged(fControl)
  else
    fNotifyRegisterUnchanged(fControl);
end;

procedure TComponentValueChangedControlEntry.StoreOldValue;
begin
  fValueChanged := False;
end;

{ TComponentValueChangedEditEntry }

constructor TComponentValueChangedEditEntry.Create(const aControl: TEdit;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aControl, aControl.OnChange, aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedEditEntry.OnChanged(Sender: TObject);
begin
  NotifyValueChanged(fOldValue <> fControl.Text);
end;

procedure TComponentValueChangedEditEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.Text;
end;

{ TComponentValueChangedComboboxEntry }

constructor TComponentValueChangedComboboxEntry.Create(const aControl: TComboBox;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aControl, aControl.OnChange, aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedComboboxEntry.OnChanged(Sender: TObject);
begin
  NotifyValueChanged(fOldValue <> fControl.ItemIndex);
end;

procedure TComponentValueChangedComboboxEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.ItemIndex;
end;

{ TComponentValueChangedCheckboxEntry }

constructor TComponentValueChangedCheckboxEntry.Create(const aControl: TCheckbox;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aControl, aControl.OnClick, aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  aControl.OnClick := OnChanged;
end;

procedure TComponentValueChangedCheckboxEntry.OnChanged(Sender: TObject);
begin
  NotifyValueChanged(fOldValue <> fControl.Checked);
end;

procedure TComponentValueChangedCheckboxEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.Checked;
end;

{ TComponentValueChangedDateTimePickerEntry }

constructor TComponentValueChangedDateTimePickerEntry.Create(const aControl: TDateTimePicker;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aControl, aControl.OnClick, aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedDateTimePickerEntry.OnChanged(Sender: TObject);
begin
  NotifyValueChanged(fOldValue <> fControl.DateTime);
end;

procedure TComponentValueChangedDateTimePickerEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.DateTime;
end;

end.
