unit StringTools;

interface

type
  TStringTools = class
  public
    class function Combine(const aStrA, aGlue, aStrB: string): string;
  end;

implementation

{ TStringTools }

class function TStringTools.Combine(const aStrA, aGlue, aStrB: string): string;
begin
  Result := aStrA;
  if (Length(aStrA) > 0) and (Length(aStrB) > 0) then
    Result := Result + aGlue;
  Result := Result + aStrB;
end;

end.
