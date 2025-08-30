unit ValidatableValueControlsRegistry;

interface

uses System.Generics.Collections, Vcl.Controls, Vcl.Forms, ConstraintControls.ConstraintEdit;

type
  TValidatableValueControlsRegistryEntry = class
  strict private
    fForm: TForm;
    fCancelControl: TWinControl;
    fControl: IValidatableValueControl;
    fOnExitQueryValidation: TOnExitQueryValidation;
    procedure ExitQueryValidation(Sender: TObject; var aValidationNeeded: Boolean);
  public
    constructor Create(const aControl: IValidatableValueControl);
    property Control: IValidatableValueControl read fControl;
    property Form: TForm read fForm write fForm;
    property CancelControl: TWinControl read fCancelControl write fCancelControl;
  end;

  TValidatableValueControlsRegistry = class
  strict private
    fForm: TForm;
    fCancelControl: TWinControl;
    fRegistry: TObjectList<TValidatableValueControlsRegistryEntry>;
    procedure SetForm(const aValue: TForm);
    procedure SetCancelControl(const aValue: TWinControl);
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterControl(const aControl: IValidatableValueControl);
    function ValidateValues: Boolean;
    property Form: TForm read fForm write SetForm;
    property CancelControl: TWinControl read fCancelControl write SetCancelControl;
  end;

implementation

{ TValidatableValueControlsRegistry }

constructor TValidatableValueControlsRegistry.Create;
begin
  inherited Create;
  fRegistry := TObjectList<TValidatableValueControlsRegistryEntry>.Create;
end;

destructor TValidatableValueControlsRegistry.Destroy;
begin
  fRegistry.Free;
  inherited;
end;

procedure TValidatableValueControlsRegistry.RegisterControl(const aControl: IValidatableValueControl);
begin
  var lEntry := TValidatableValueControlsRegistryEntry.Create(aControl);
  lEntry.Form := fForm;
  lEntry.CancelControl := fCancelControl;
  fRegistry.Add(lEntry);
end;

procedure TValidatableValueControlsRegistry.SetForm(const aValue: TForm);
begin
  fForm := aValue;
  for var i in fRegistry do
    i.Form := fForm;
end;

procedure TValidatableValueControlsRegistry.SetCancelControl(const aValue: TWinControl);
begin
  fCancelControl := aValue;
  for var i in fRegistry do
    i.CancelControl := fCancelControl;
end;

function TValidatableValueControlsRegistry.ValidateValues: Boolean;
begin
  Result := True;
  var lActiveControl := fForm.ActiveControl;
  for var i in fRegistry do
  begin
    if lActiveControl <> i.Control.Control then
      Continue;
    if not i.Control.ValidateValue then
    begin
      i.Control.SetFocus;
      Exit(False);
    end;
  end;
end;

{ TValidatableValueControlsRegistryEntry }

constructor TValidatableValueControlsRegistryEntry.Create(const aControl: IValidatableValueControl);
begin
  inherited Create;
  fControl := aControl;
  fOnExitQueryValidation := fControl.OnExitQueryValidation;
  fControl.OnExitQueryValidation := ExitQueryValidation;
end;

procedure TValidatableValueControlsRegistryEntry.ExitQueryValidation(Sender: TObject; var aValidationNeeded: Boolean);
begin
  if fForm.ActiveControl = fCancelControl then
  begin
    aValidationNeeded := False;
  end;
  if Assigned(fOnExitQueryValidation) then
    fOnExitQueryValidation(fControl.Control, aValidationNeeded);
end;

end.
