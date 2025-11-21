unit Helper.WinControl;

interface

uses Vcl.Controls;

type
  IWinControlDisabledScope = interface
    ['{F6EA316C-D0F0-474D-B82A-F6E9ADD40D88}']
    procedure Disable;
    procedure Restore;
  end;

  TWinControlHelper = class helper for TWinControl
  public
    function GetDisabledScope: IWinControlDisabledScope;
  end;

implementation

uses System.Generics.Collections, InterfacedBase;

type
  TWinControlDisabledScope = class(TInterfacedBase, IWinControlDisabledScope)
  strict private
    fWinControl: TWinControl;
    fEnabledStates: TDictionary<TControl, Boolean>;
    procedure DisableControl(const aControl: TControl);
    procedure Disable;
    procedure Restore;
  public
    constructor Create(const aWinControl: TWinControl);
    destructor Destroy; override;
  end;

{ TWinControlHelper }

function TWinControlHelper.GetDisabledScope: IWinControlDisabledScope;
begin
  Result := TWinControlDisabledScope.Create(Self);
end;

{ TWinControlDisabledScope }

constructor TWinControlDisabledScope.Create(const aWinControl: TWinControl);
begin
  inherited Create;
  fWinControl := aWinControl;
  fEnabledStates := TDictionary<TControl, Boolean>.Create;
end;

destructor TWinControlDisabledScope.Destroy;
begin
  Restore;
  fEnabledStates.Free;
  inherited;
end;

procedure TWinControlDisabledScope.Disable;
begin
  fEnabledStates.Clear;
  DisableControl(fWinControl);
end;

procedure TWinControlDisabledScope.DisableControl(const aControl: TControl);
begin
  fEnabledStates.Add(aControl, aControl.Enabled);
  aControl.Enabled := False;
  if aControl is TWinControl then
  begin
    var lWinControl := aControl as TWinControl;
    for var i := 0 to lWinControl.ControlCount - 1 do
      DisableControl(lWinControl.Controls[i]);
  end;
end;

procedure TWinControlDisabledScope.Restore;
begin
  for var lEntry in fEnabledStates do
    lEntry.Key.Enabled := lEntry.Value;
  fEnabledStates.Clear;
end;

end.
