unit DtoPerson;

interface

uses DtoPersonNameId;

type
  TDtoPerson = record
    NameId: TDtoPersonNameId;
    Active: Boolean;
    &External: Boolean;
    Birthday: TDate;
    OnBirthdayList: Boolean;
    function ToString: string;
  end;

implementation

uses System.SysUtils, StringTools;

{ TDtoPerson }

function TDtoPerson.ToString: string;
begin
  Result := NameId.ToString;
end;

end.
