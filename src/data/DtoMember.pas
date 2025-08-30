unit DtoMember;

interface

uses Nullable;

type
  TDtoMember = record
    Id: UInt32;
    PersonId: UInt32;
    UnitId: UInt32;
    RoleId: UInt32;
    Active: Boolean;
    ActiveSince: INullable<TDate>;
    ActiveUntil: INullable<TDate>;
    class operator Initialize(out Dest: TDtoMember);
    class operator Finalize(var Dest: TDtoMember);
  end;

implementation

class operator TDtoMember.Initialize(out Dest: TDtoMember);
begin
  Dest.ActiveSince := TNullable<TDate>.Create;
  Dest.ActiveUntil := TNullable<TDate>.Create;
end;

class operator TDtoMember.Finalize(var Dest: TDtoMember);
begin
  Dest.ActiveSince := nil;
  Dest.ActiveUntil := nil;
end;

end.
