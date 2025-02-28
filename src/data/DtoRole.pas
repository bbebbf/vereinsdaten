unit DtoRole;

interface

type
  TDtoRole = record
    Id: UInt32;
    Name: string;
    Active: Boolean;
    Sorting: UInt8;
    function ToString: string;
  end;

implementation

uses System.SysUtils;

{ TDtoRole }

function TDtoRole.ToString: string;
begin
  Result := Name;
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
