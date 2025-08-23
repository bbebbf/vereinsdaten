unit ComponentValueChangedObserver;

interface

uses System.Classes, System.Generics.Collections, Vcl.Controls, Vcl.StdCtrls, Vcl.ComCtrls,
  ConstraintControls.IntegerEdit, ConstraintControls.DateEdit, SimpleDate;

type
  TComponentValueChangedControlEntry = class
  strict private
    fValueChanged: Boolean;
    fNotifyRegisterChanged: TNotifyEvent;
    fNotifyRegisterUnchanged: TNotifyEvent;
  strict protected
    procedure NotifyValueChanged(const aControl: TControl; const aValueChanged: Boolean);
  public
    constructor Create(const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; virtual;
  end;

  TComponentValueChangedEditEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TEdit;
    fOriginalChangedEvent: TNotifyEvent;
    fOldValue: string;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TEdit; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedIntegerEditEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TIntegerEdit;
    fOriginalChangedEvent: TNotifyEvent;
    fOldValue: Int64;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TIntegerEdit; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedDateEditEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TDateEdit;
    fOriginalChangedEvent: TNotifyEvent;
    fOldValue: TSimpleDate;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TDateEdit; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedCheckboxEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TCheckbox;
    fOriginalClickEvent: TNotifyEvent;
    fOldValue: Boolean;
    procedure OnChanged(Sender: TObject);
  public
    constructor Create(const aControl: TCheckbox; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedComboboxEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TComboBox;
    fOriginalChangedEvent: TNotifyEvent;
    fOriginalSelectEvent: TNotifyEvent;
    fOldItemIndex: Integer;
    fOldText: string;
    procedure OnChanged(Sender: TObject);
    procedure OnSelect(Sender: TObject);
  public
    constructor Create(const aControl: TComboBox; const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
    procedure StoreOldValue; override;
  end;

  TComponentValueChangedDateTimePickerEntry = class(TComponentValueChangedControlEntry)
  strict private
    fControl: TDateTimePicker;
    fOriginalChangedEvent: TNotifyEvent;
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
    function GetInUpdated: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterEdit(const aEdit: TEdit); overload;
    procedure RegisterEdit(const aIntegerEdit: TIntegerEdit); overload;
    procedure RegisterEdit(const aDateEdit: TDateEdit); overload;
    procedure RegisterCheckbox(const aCheckbox: TCheckBox);
    procedure RegisterCombobox(const aCombobox: TCombobox);
    procedure RegisterDateTimePicker(const aDateTimePicker: TDateTimePicker);
    procedure BeginUpdate;
    procedure EndUpdate;
    property InUpdated: Boolean read GetInUpdated;
    property OnValuesChanged: TNotifyEvent read fOnValuesChanged write fOnValuesChanged;
    property OnValuesUnchanged: TNotifyEvent read fOnValuesUnchanged write fOnValuesUnchanged;
    property OnComponentValueChangedEvent: TComponentValueChangedEvent read fOnComponentValueChangedEvent
      write fOnComponentValueChangedEvent;
    property OnComponentValueUnchangedEvent: TComponentValueChangedEvent read fOnComponentValueUnchangedEvent
      write fOnComponentValueUnchangedEvent;
  end;

implementation

procedure CallNotifyEvent(const aControl: TControl; const aEvent: TNotifyEvent);
begin
  if Assigned(aEvent) then
    aEvent(aControl);
end;

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

function TComponentValueChangedObserver.GetInUpdated: Boolean;
begin
  Result := fInUpdate > 0;
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

procedure TComponentValueChangedObserver.RegisterEdit(const aDateEdit: TDateEdit);
begin
  fRegister.AddOrSetValue(aDateEdit,
    TComponentValueChangedDateEditEntry.Create(aDateEdit, ControlChanged, ControlUnChanged));
end;

procedure TComponentValueChangedObserver.RegisterEdit(const aIntegerEdit: TIntegerEdit);
begin
  fRegister.AddOrSetValue(aIntegerEdit,
    TComponentValueChangedIntegerEditEntry.Create(aIntegerEdit, ControlChanged, ControlUnChanged));
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

constructor TComponentValueChangedControlEntry.Create(const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create;
  fNotifyRegisterChanged := aNotifyRegisterChanged;
  fNotifyRegisterUnchanged := aNotifyRegisterUnchanged;
end;

procedure TComponentValueChangedControlEntry.NotifyValueChanged(const aControl: TControl; const aValueChanged: Boolean);
begin
  if fValueChanged = aValueChanged then
    Exit;

  fValueChanged := aValueChanged;
  if fValueChanged then
    fNotifyRegisterChanged(aControl)
  else
    fNotifyRegisterUnchanged(aControl);
end;

procedure TComponentValueChangedControlEntry.StoreOldValue;
begin
  fValueChanged := False;
end;

{ TComponentValueChangedEditEntry }

constructor TComponentValueChangedEditEntry.Create(const aControl: TEdit;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalChangedEvent := aControl.OnChange;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedEditEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalChangedEvent);
  NotifyValueChanged(fControl, fOldValue <> fControl.Text);
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
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalChangedEvent := aControl.OnChange;
  aControl.OnChange := OnChanged;
  fOriginalSelectEvent := aControl.OnSelect;
  aControl.OnSelect := OnSelect;
end;

procedure TComponentValueChangedComboboxEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalChangedEvent);
  NotifyValueChanged(fControl, (fOldText <> fControl.Text) or (fOldItemIndex <> fControl.ItemIndex));
end;

procedure TComponentValueChangedComboboxEntry.OnSelect(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalSelectEvent);
  NotifyValueChanged(fControl, (fOldText <> fControl.Text) or (fOldItemIndex <> fControl.ItemIndex));
end;

procedure TComponentValueChangedComboboxEntry.StoreOldValue;
begin
  inherited;
  fOldItemIndex := fControl.ItemIndex;
  fOldText := fControl.Text;
end;

{ TComponentValueChangedCheckboxEntry }

constructor TComponentValueChangedCheckboxEntry.Create(const aControl: TCheckbox;
  const aNotifyRegisterChanged, aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalClickEvent := aControl.OnClick;
  aControl.OnClick := OnChanged;
end;

procedure TComponentValueChangedCheckboxEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalClickEvent);
  NotifyValueChanged(fControl, fOldValue <> fControl.Checked);
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
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalChangedEvent := aControl.OnChange;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedDateTimePickerEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalChangedEvent);
  NotifyValueChanged(fControl, fOldValue <> fControl.DateTime);
end;

procedure TComponentValueChangedDateTimePickerEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.DateTime;
end;

{ TComponentValueChangedIntegerEditEntry }

constructor TComponentValueChangedIntegerEditEntry.Create(const aControl: TIntegerEdit; const aNotifyRegisterChanged,
  aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalChangedEvent := aControl.OnChange;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedIntegerEditEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalChangedEvent);
  NotifyValueChanged(fControl, fOldValue <> fControl.Value.Value);
end;

procedure TComponentValueChangedIntegerEditEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.Value.Value;
end;

{ TComponentValueChangedDateEditEntry }

constructor TComponentValueChangedDateEditEntry.Create(const aControl: TDateEdit; const aNotifyRegisterChanged,
  aNotifyRegisterUnchanged: TNotifyEvent);
begin
  inherited Create(aNotifyRegisterChanged, aNotifyRegisterUnchanged);
  fControl := aControl;
  fOriginalChangedEvent := aControl.OnChange;
  aControl.OnChange := OnChanged;
end;

procedure TComponentValueChangedDateEditEntry.OnChanged(Sender: TObject);
begin
  CallNotifyEvent(fControl, fOriginalChangedEvent);
  NotifyValueChanged(fControl, fOldValue <> fControl.Value.Value);
end;

procedure TComponentValueChangedDateEditEntry.StoreOldValue;
begin
  inherited;
  fOldValue := fControl.Value.Value;
end;

end.
