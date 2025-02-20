unit ActionlistWrapper;

interface

uses System.Generics.Collections, System.Actions, Vcl.ActnList;

type
  TActionlistWrapper = class
  strict private
    fActionList: TActionList;
    fActionEnabledDict: TDictionary<TContainedAction, Boolean>;
    fEnabled: Boolean;
    procedure SetEnabled(const aValue: Boolean);
  public
    constructor Create(const aActionList: TActionList);
    destructor Destroy; override;
    procedure SetActionEnabled(const aAction: TContainedAction; const aEnabled: Boolean);
    property Enabled: Boolean read fEnabled write SetEnabled;
  end;

implementation

{ TActionlistWrapper }

constructor TActionlistWrapper.Create(const aActionList: TActionList);
begin
  inherited Create;
  fActionList := aActionList;
  fEnabled := True;
  fActionEnabledDict := TDictionary<TContainedAction, Boolean>.Create;
end;

destructor TActionlistWrapper.Destroy;
begin
  fActionEnabledDict.Free;
  inherited;
end;

procedure TActionlistWrapper.SetActionEnabled(const aAction: TContainedAction; const aEnabled: Boolean);
begin
  if fEnabled then
  begin
    aAction.Enabled := aEnabled;
  end
  else if fActionEnabledDict.ContainsKey(aAction) then
  begin
    fActionEnabledDict.AddOrSetValue(aAction, aEnabled);
  end;
end;

procedure TActionlistWrapper.SetEnabled(const aValue: Boolean);
begin
  if fEnabled = aValue then
    Exit;

  fEnabled := aValue;
  if fEnabled then
  begin
    fActionList.State := TActionListState.asNormal;
    for var lAction in fActionList do
    begin
      var lEnabled: Boolean;
      if fActionEnabledDict.TryGetValue(lAction, lEnabled) then
      begin
        lAction.Enabled := lEnabled;
      end;
    end;
  end
  else
  begin
    fActionEnabledDict.Clear;
    for var lAction in fActionList do
    begin
      fActionEnabledDict.Add(lAction, lAction.Enabled);
      lAction.Enabled := False;
    end;
    fActionList.State := TActionListState.asSuspended;
  end;
end;

end.

