unit DtoPerson;

interface

type
  TDtoPerson = record
    Id: Int32;
    Vorname: string;
    Praeposition: string;
    Nachname: string;
    Aktiv: Boolean;
    Geburtsdatum: TDate;
    AddressId: Integer;
    function ToString: string;
  end;

implementation

uses System.SysUtils, StringTools;

{ TDtoPerson }

function TDtoPerson.ToString: string;
begin
  Result := TStringTools.Combine(Nachname, ', ', TStringTools.Combine(Vorname, ' ', Praeposition));
{$ifdef DEBUG}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

end.
