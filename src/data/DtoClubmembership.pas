unit DtoClubmembership;

interface

uses Nullable;

type
  TDtoClubmembership = record
    Id: UInt32;
    PersonId: UInt32;
    Number: UInt16;
    Active: Boolean;
    Startdate: INullable<TDate>;
    Enddate: INullable<TDate>;
    EnddateStr: string;
    Endreason: string;
    class operator Initialize(out Dest: TDtoClubmembership);
    class operator Finalize(var Dest: TDtoClubmembership);
  end;

implementation

{ TDtoClubmembership }

class operator TDtoClubmembership.Initialize(out Dest: TDtoClubmembership);
begin
  Dest.Startdate := TNullable<TDate>.Create;
  Dest.Enddate := TNullable<TDate>.Create;
end;

class operator TDtoClubmembership.Finalize(var Dest: TDtoClubmembership);
begin
  Dest.Startdate := nil;
  Dest.Enddate := nil;
end;

end.
