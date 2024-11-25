unit DtoPersonAggregated;

interface

uses DtoPerson;

type
  TDtoPersonAggregated = class
  strict private
    fPerson: TDtoPerson;
    fAddressIndex: Integer;
    fCreateNewAddress: Boolean;
    fNewAddressStreet: string;
    fNewAddressPostalcode: string;
    fNewAddressCity: string;
  public
    constructor Create(const aPerson: TDtoPerson);
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
  end;

implementation

{ TDtoPersonAggregated }

constructor TDtoPersonAggregated.Create(const aPerson: TDtoPerson);
begin
  inherited Create;
  fPerson := aPerson;
  fAddressIndex := -1;
end;

end.
