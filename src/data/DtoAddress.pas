unit DtoAddress;

interface

type
  TDtoAddress = record
    Id: UInt32;
    Street: string;
    Postalcode: string;
    City: string;
    function ToString: string;
  end;

implementation

uses System.SysUtils, StringTools;

{ TDtoAddress }

function TDtoAddress.ToString: string;
begin
  Result := TStringTools.Combine(Street, ', ', TStringTools.Combine(Postalcode, ' ', City));
{$ifdef DEBUG}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;


end.
