unit Nullable;

interface

type
  INullable<T> = interface
    ['{DFFBD6FF-CDF1-41F5-A601-38315116F623}']
    procedure Assign(const aValue: INullable<T>);
    procedure Reset;
    function GetValue: T;
    procedure SetValue(const aValue: T);
    function GetHasValue: Boolean;
    property Value: T read GetValue write SetValue;
    property HasValue: Boolean read GetHasValue;
  end;

  TNullable<T> = class(TInterfacedObject, INullable<T>)
  strict private
    fHasValue: Boolean;
    fValue: T;
    procedure Assign(const aValue: INullable<T>);
    procedure Reset;
    function GetValue: T;
    procedure SetValue(const aValue: T);
    function GetHasValue: Boolean;
  public
    constructor Create; overload;
    constructor Create(const aValue: T); overload;
  end;

implementation

{ TNullable<T> }

constructor TNullable<T>.Create(const aValue: T);
begin
  inherited Create;
  SetValue(aValue);
end;

constructor TNullable<T>.Create;
begin
  inherited Create;
end;

procedure TNullable<T>.Assign(const aValue: INullable<T>);
begin
  if aValue.HasValue then
    SetValue(aValue.Value)
  else
    Reset;
end;

function TNullable<T>.GetHasValue: Boolean;
begin
  Result := fHasValue;
end;

function TNullable<T>.GetValue: T;
begin
  if fHasValue then
    Result := fValue
  else
    Result := default(T);
end;

procedure TNullable<T>.Reset;
begin
  fValue := default(T);
  fHasValue := False;
end;

procedure TNullable<T>.SetValue(const aValue: T);
begin
  fValue := aValue;
  fHasValue := True;
end;

end.
