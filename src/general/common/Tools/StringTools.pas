unit StringTools;

interface

type
  TStringTools = class
  public
    class function Combine(const aStrA, aGlue, aStrB: string): string;
    class function IsEmpty(const aString: string): Boolean;
  end;

implementation

uses System.SysUtils;

{ TStringTools }

class function TStringTools.Combine(const aStrA, aGlue, aStrB: string): string;
begin
  Result := aStrA;
  if (Length(aStrA) > 0) and (Length(aStrB) > 0) then
    Result := Result + aGlue;
  Result := Result + aStrB;
end;

class function TStringTools.IsEmpty(const aString: string): Boolean;
begin
  Result := Length(Trim(aString)) = 0;
end;

end.
