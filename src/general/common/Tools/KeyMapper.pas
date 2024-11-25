unit KeyMapper;

interface

uses System.Generics.Collections;

type
  TKeyMapper<TKA, TKB> = class
  strict private
    fKeyANotFoundValue: TKA;
    fKeyBNotFoundValue: TKB;
    fAToB: TDictionary<TKA, TKB>;
    fBToA: TDictionary<TKB, TKA>;
  public
    constructor Create(const aKeyANotFoundValue: TKA; const aKeyBNotFoundValue: TKB);
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const aKeyA: TKA; const aKeyB: TKB);
    function TryGetKeyA(const aKeyB: TKB; out aKeyA: TKA): Boolean;
    function TryGetKeyB(const aKeyA: TKA; out aKeyB: TKB): Boolean;
    function GetKeyA(const aKeyB: TKB): TKA;
    function GetKeyB(const aKeyA: TKA): TKB;
  end;

implementation

{ TKeyMapper<TKA, TKB> }

constructor TKeyMapper<TKA, TKB>.Create(const aKeyANotFoundValue: TKA; const aKeyBNotFoundValue: TKB);
begin
  inherited Create;
  fKeyANotFoundValue := aKeyANotFoundValue;
  fKeyBNotFoundValue := aKeyBNotFoundValue;
  fAToB := TDictionary<TKA, TKB>.Create;
  fBToA := TDictionary<TKB, TKA>.Create;
end;

destructor TKeyMapper<TKA, TKB>.Destroy;
begin
  fBToA.Free;
  fAToB.Free;
  inherited;
end;

procedure TKeyMapper<TKA, TKB>.Add(const aKeyA: TKA; const aKeyB: TKB);
begin
  fAToB.AddOrSetValue(aKeyA, aKeyB);
  fBToA.AddOrSetValue(aKeyB, aKeyA);
end;

function TKeyMapper<TKA, TKB>.GetKeyA(const aKeyB: TKB): TKA;
begin
  if not TryGetKeyA(aKeyB, Result) then
    Result := fKeyANotFoundValue;
end;

function TKeyMapper<TKA, TKB>.GetKeyB(const aKeyA: TKA): TKB;
begin
  if not TryGetKeyB(aKeyA, Result) then
    Result := fKeyBNotFoundValue;
end;

function TKeyMapper<TKA, TKB>.TryGetKeyA(const aKeyB: TKB; out aKeyA: TKA): Boolean;
begin
  Result := fBToA.TryGetValue(aKeyB, aKeyA);
end;

function TKeyMapper<TKA, TKB>.TryGetKeyB(const aKeyA: TKA; out aKeyB: TKB): Boolean;
begin
  Result := fAToB.TryGetValue(aKeyA, aKeyB);
end;

procedure TKeyMapper<TKA, TKB>.Clear;
begin
  fAToB.Clear;
  fBToA.Clear;
end;

end.
