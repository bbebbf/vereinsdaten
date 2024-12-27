unit DtoPersonNameId;

interface

type
  TDtoPersonNameId = record
    Id: UInt32;
    Vorname: string;
    Praeposition: string;
    Nachname: string;
    function ToString: string;
  end;

implementation

uses System.SysUtils, StringTools;

{ TDtoPersonNameId }

function TDtoPersonNameId.ToString: string;
begin
  Result := TStringTools.Combine(Nachname, ', ', TStringTools.Combine(Vorname, ' ', Praeposition));
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
