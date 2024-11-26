unit DtoClubmembership;

interface

type
  TDtoClubmembership = record
    Id: Int32;
    PersonId: Int32;
    Number: UInt16;
    Active: Boolean;
    Startdate: TDate;
    Enddate: TDate;
    EnddateStr: string;
    Endreason: string;
  end;

implementation

end.
