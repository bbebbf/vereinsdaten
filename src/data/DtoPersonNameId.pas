unit DtoPersonNameId;

interface

type
  TDtoPersonNameId = record
    Id: UInt32;
    Firstname: string;
    NameAddition: string;
    Lastname: string;
    function ToString: string;
  end;

implementation

uses System.SysUtils, StringTools;

{ TDtoPersonNameId }

function TDtoPersonNameId.ToString: string;
begin
  Result := TStringTools.Combine(Lastname, ', ', TStringTools.Combine(Firstname, ' ', NameAddition));
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
