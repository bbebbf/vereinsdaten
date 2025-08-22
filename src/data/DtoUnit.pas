unit DtoUnit;

interface

type
  TUnitKind = (DefaultKind, OneTimeKind, ExternalKind);

  TDtoUnit = record
    Id: UInt32;
    Name: string;
    Active: Boolean;
    ActiveSince: TDate;
    ActiveUntil: TDate;
    Kind: TUnitKind;
    DataConfirmedOn: TDate;
    function ToString: string;
  end;

function UnitKindToStr(const aKind: TUnitKind): string;

implementation

uses System.SysUtils;

{ TDtoUnit }

function TDtoUnit.ToString: string;
begin
  Result := Name;
{$ifdef INTERNAL_DB_ID_VISIBLE}
  Result := Result + ' (' + IntToStr(Id) + ')';
{$endif}
end;

function UnitKindToStr(const aKind: TUnitKind): string;
begin
  case aKind of
    TUnitKind.DefaultKind:
      Result := 'Standard';
    TUnitKind.OneTimeKind:
      Result := 'Einmalig';
    TUnitKind.ExternalKind:
      Result := 'Extern';
    else
      Result := '???';
  end;
end;

end.
