unit DtoPersonAggregated;

interface

uses DtoPerson, DtoClubmembership;

type
  TDtoPersonAggregated = class
  strict private
    fPerson: TDtoPerson;
    fAddressIndex: Integer;
    fCreateNewAddress: Boolean;
    fNewAddressStreet: string;
    fNewAddressPostalcode: string;
    fNewAddressCity: string;
    fMembershipNoMembership: Boolean;
    fMembershipId: Int32;
    fMembershipActive: Boolean;
    fMembershipNumber: UInt16;
    fMembershipBeginDate: TDate;
    fMembershipEndDate: TDate;
    fMembershipEndDateText: string;
    fMembershipEndReason: string;
  public
    constructor Create(const aPerson: TDtoPerson);
    function GetDtoClubmembership: TDtoClubmembership;
    procedure SetDtoClubmembership(const aValue: TDtoClubmembership);
    property Person: TDtoPerson read fPerson;
    property Id: Int32 read fPerson.Id write fPerson.Id;
    property Firstname: string read fPerson.Vorname write fPerson.Vorname;
    property Praeposition: string read fPerson.Praeposition write fPerson.Praeposition;
    property Lastname: string read fPerson.Nachname write fPerson.Nachname;
    property Active: Boolean read fPerson.Aktiv write fPerson.Aktiv;
    property Birthday: TDate read fPerson.Geburtsdatum write fPerson.Geburtsdatum;
    property AddressIndex: Integer read fAddressIndex write fAddressIndex;
    property CreateNewAddress: Boolean read fCreateNewAddress write fCreateNewAddress;
    property NewAddressStreet: string read fNewAddressStreet write fNewAddressStreet;
    property NewAddressPostalcode: string read fNewAddressPostalcode write fNewAddressPostalcode;
    property NewAddressCity: string read fNewAddressCity write fNewAddressCity;

    property MembershipNoMembership: Boolean read fMembershipNoMembership write fMembershipNoMembership;
    property MembershipId: Int32 read fMembershipId write fMembershipId;
    property MembershipActive: Boolean read fMembershipActive write fMembershipActive;
    property MembershipNumber: UInt16 read fMembershipNumber write fMembershipNumber;
    property MembershipBeginDate: TDate read fMembershipBeginDate write fMembershipBeginDate;
    property MembershipEndDate: TDate read fMembershipEndDate write fMembershipEndDate;
    property MembershipEndDateText: string read fMembershipEndDateText write fMembershipEndDateText;
    property MembershipEndReason: string read fMembershipEndReason write fMembershipEndReason;
  end;

implementation

{ TDtoPersonAggregated }

constructor TDtoPersonAggregated.Create(const aPerson: TDtoPerson);
begin
  inherited Create;
  fPerson := aPerson;
  fAddressIndex := -1;
end;

function TDtoPersonAggregated.GetDtoClubmembership: TDtoClubmembership;
begin
  Result := default(TDtoClubmembership);
  Result.Id := fMembershipId;
  Result.PersonId := fPerson.Id;
  Result.Active := fMembershipActive;
  Result.Number := fMembershipNumber;
  Result.Startdate := fMembershipBeginDate;
  Result.Enddate := fMembershipEndDate;
  Result.EnddateStr := fMembershipEndDateText;
  Result.Endreason := fMembershipEndReason;
end;

procedure TDtoPersonAggregated.SetDtoClubmembership(const aValue: TDtoClubmembership);
begin
  fMembershipId := aValue.Id;
  fMembershipActive := aValue.Active;
  fMembershipNumber := aValue.Number;
  fMembershipBeginDate := aValue.Startdate;
  fMembershipEndDate := aValue.Enddate;
  fMembershipEndDateText := aValue.EnddateStr;
  fMembershipEndReason := aValue.Endreason;
end;

end.
