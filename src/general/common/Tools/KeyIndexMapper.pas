unit KeyIndexMapper;

interface

uses KeyMapper;

type
  TKeyIndexMapper<T> = class(TKeyMapper<T, Integer>)
  public
    constructor Create(const aKeyNotFoundValue: T; const aIndexNotFoundValue: Integer = -1);
    function TryGetKey(const aIndex: Integer; out aKey: T): Boolean;
    function TryGetIndex(const aKey: T; out aIndex: Integer): Boolean;
    function GetKey(const aIndex: Integer): T;
    function GetIndex(const aKey: T): Integer;
  end;

implementation

{ TKeyIndexMapper<T> }

constructor TKeyIndexMapper<T>.Create(const aKeyNotFoundValue: T; const aIndexNotFoundValue: Integer);
begin
  inherited Create(aKeyNotFoundValue, aIndexNotFoundValue);
end;

function TKeyIndexMapper<T>.GetIndex(const aKey: T): Integer;
begin
  Result := GetKeyB(aKey);
end;

function TKeyIndexMapper<T>.GetKey(const aIndex: Integer): T;
begin
  Result := GetKeyA(aIndex);
end;

function TKeyIndexMapper<T>.TryGetIndex(const aKey: T; out aIndex: Integer): Boolean;
begin
  Result := TryGetKeyB(aKey, aIndex);
end;

function TKeyIndexMapper<T>.TryGetKey(const aIndex: Integer; out aKey: T): Boolean;
begin
  Result := TryGetKeyA(aIndex, aKey);
end;

end.
