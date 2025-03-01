unit DtoAddress;

interface

type
  TDtoAddress = record
    Id: UInt32;
    Active: Boolean;
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
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;


end.
