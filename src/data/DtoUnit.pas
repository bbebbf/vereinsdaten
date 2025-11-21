unit DtoUnit;

interface

uses Nullable;

type
  TUnitKind = (DefaultKind, OneTimeKind, ExternalKind);
  TUnitKinds = set of TUnitKind;

  TDtoUnit = record
    Id: UInt32;
    Name: string;
    Active: Boolean;
    ActiveSince: INullable<TDate>;
    ActiveUntil: INullable<TDate>;
    Kind: TUnitKind;
    DataConfirmedOn: INullable<TDate>;
    function ToString: string;
    class operator Initialize(out Dest: TDtoUnit);
    class operator Finalize(var Dest: TDtoUnit);
  end;

function UnitKindToStr(const aKind: TUnitKind): string;
function UnitKindToStrShort(const aKind: TUnitKind): string;

implementation

uses System.SysUtils;

{ TDtoUnit }

class operator TDtoUnit.Initialize(out Dest: TDtoUnit);
begin
  Dest.ActiveSince := TNullable<TDate>.Create;
  Dest.ActiveUntil := TNullable<TDate>.Create;
  Dest.DataConfirmedOn := TNullable<TDate>.Create;
end;

class operator TDtoUnit.Finalize(var Dest: TDtoUnit);
begin
  Dest.ActiveSince := nil;
  Dest.ActiveUntil := nil;
  Dest.DataConfirmedOn := nil;
end;

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

function UnitKindToStrShort(const aKind: TUnitKind): string;
begin
  case aKind of
    TUnitKind.OneTimeKind:
      Result := 'Ein';
    TUnitKind.ExternalKind:
      Result := 'Ext';
    else
      Result := '';
  end;
end;

end.
