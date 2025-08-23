unit DtoPerson;

interface

uses DtoPersonNameId, SimpleDate, Nullable;

type
  TDtoPerson = record
    NameId: TDtoPersonNameId;
    Active: Boolean;
    &External: Boolean;
    Birthday: INullable<TSimpleDate>;
    OnBirthdayList: Boolean;
    function ToString: string;
    class operator Initialize(out Dest: TDtoPerson);
    class operator Finalize(var Dest: TDtoPerson);
  end;

implementation

{ TDtoPerson }

class operator TDtoPerson.Initialize(out Dest: TDtoPerson);
begin
  Dest.Birthday := TNullable<TSimpleDate>.Create;
end;

class operator TDtoPerson.Finalize(var Dest: TDtoPerson);
begin
  Dest.Birthday := nil;
end;

function TDtoPerson.ToString: string;
begin
  Result := NameId.ToString;
end;

end.
