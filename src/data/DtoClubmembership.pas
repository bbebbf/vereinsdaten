unit DtoClubmembership;

interface

type
  TDtoClubmembership = record
    Id: UInt32;
    PersonId: UInt32;
    Number: UInt16;
    Active: Boolean;
    Startdate: TDate;
    Enddate: TDate;
    EnddateStr: string;
    Endreason: string;
  end;

implementation

end.
