unit DtoUnit;

interface

type
  TDtoUnit = record
    Id: UInt32;
    Name: string;
    Active: Boolean;
    ActiveSince: TDate;
    ActiveUntil: TDate;
    function ToString: string;
  end;

implementation

uses System.SysUtils;

{ TDtoUnit }

function TDtoUnit.ToString: string;
begin
  Result := Name;
{$ifdef DEBUG}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
