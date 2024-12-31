unit DtoTenant;

interface

type
  TDtoTenant = record
    Id: UInt8;
    Title: string;
    function ToString: string;
  end;

implementation

uses System.SysUtils;

{ TDtoTenant }

function TDtoTenant.ToString: string;
begin
  Result := Title;
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
