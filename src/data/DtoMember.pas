unit DtoMember;

interface

type
  TDtoMember = record
    Id: UInt32;
    PersonId: UInt32;
    UnitId: UInt32;
    RoleId: UInt32;
    Active: Boolean;
    ActiveSince: TDate;
    ActiveUntil: TDate;
  end;

implementation

end.
