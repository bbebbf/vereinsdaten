unit DtoPersonAggregated;

interface

uses DtoPerson, DtoClubmembership, KeyIndexStrings, Vdm.Versioning.Types;

type
  TDtoPersonAggregated = class
  strict private
    fPerson: TDtoPerson;
    fVersionInfoBaseData: TVersionInfoEntry;
    fVersionInfoMenberOfs: TVersionInfoEntry;
    fExistingAddressId: UInt32;
    fAddressId: UInt32;
    fAvailableAddresses: TKeyIndexStrings;
    fCreateNewAddress: Boolean;
    fNewAddressStreet: string;
    fNewAddressPostalcode: string;
    fNewAddressCity: string;
    fMembershipNoMembership: Boolean;
    fMembershipId: UInt32;
    fMembershipActive: Boolean;
    fMembershipNumber: UInt16;
    fMembershipBeginDate: TDate;
    fMembershipEndDate: TDate;
    fMembershipEndDateText: string;
    fMembershipEndReason: string;

    function GetAddressIndex: Integer;
    procedure SetAddressIndex(const aValue: Integer);
  public
    constructor Create(const aPerson: TDtoPerson; const aExistingAddressId: UInt32;
      const aAvailableAddresses: TKeyIndexStrings);
    destructor Destroy; override;
    function Clone: TDtoPersonAggregated;
    function GetDtoClubmembership: TDtoClubmembership;
    procedure SetDtoClubmembership(const aValue: TDtoClubmembership);
    procedure UpdateExistingAddressId;
    property Person: TDtoPerson read fPerson;
    property VersionInfoBaseData: TVersionInfoEntry read fVersionInfoBaseData;
    property VersionInfoMenberOfs: TVersionInfoEntry read fVersionInfoMenberOfs;
    property Id: UInt32 read fPerson.NameId.Id write fPerson.NameId.Id;
    property Firstname: string read fPerson.NameId.Vorname write fPerson.NameId.Vorname;
    property Praeposition: string read fPerson.NameId.Praeposition write fPerson.NameId.Praeposition;
    property Lastname: string read fPerson.NameId.Nachname write fPerson.NameId.Nachname;
    property Active: Boolean read fPerson.Aktiv write fPerson.Aktiv;
    property Birthday: TDate read fPerson.Geburtsdatum write fPerson.Geburtsdatum;

    property ExistingAddressId: UInt32 read fExistingAddressId;
    property AddressId: UInt32 read fAddressId write fAddressId;
    property AvailableAddresses: TKeyIndexStrings read fAvailableAddresses;
    property AddressIndex: Integer read GetAddressIndex write SetAddressIndex;
    property CreateNewAddress: Boolean read fCreateNewAddress write fCreateNewAddress;
    property NewAddressStreet: string read fNewAddressStreet write fNewAddressStreet;
    property NewAddressPostalcode: string read fNewAddressPostalcode write fNewAddressPostalcode;
    property NewAddressCity: string read fNewAddressCity write fNewAddressCity;

    property MembershipNoMembership: Boolean read fMembershipNoMembership write fMembershipNoMembership;
    property MembershipId: UInt32 read fMembershipId write fMembershipId;
    property MembershipActive: Boolean read fMembershipActive write fMembershipActive;
    property MembershipNumber: UInt16 read fMembershipNumber write fMembershipNumber;
    property MembershipBeginDate: TDate read fMembershipBeginDate write fMembershipBeginDate;
    property MembershipEndDate: TDate read fMembershipEndDate write fMembershipEndDate;
    property MembershipEndDateText: string read fMembershipEndDateText write fMembershipEndDateText;
    property MembershipEndReason: string read fMembershipEndReason write fMembershipEndReason;
  end;

implementation

{ TDtoPersonAggregated }

constructor TDtoPersonAggregated.Create(const aPerson: TDtoPerson; const aExistingAddressId: UInt32;
  const aAvailableAddresses: TKeyIndexStrings);
begin
  inherited Create;
  fVersionInfoBaseData := TVersionInfoEntry.Create;
  fVersionInfoMenberOfs := TVersionInfoEntry.Create;
  fPerson := aPerson;
  fExistingAddressId := aExistingAddressId;
  fAvailableAddresses := aAvailableAddresses;
end;

destructor TDtoPersonAggregated.Destroy;
begin
  fVersionInfoMenberOfs.Free;
  fVersionInfoBaseData.Free;
  inherited;
end;

function TDtoPersonAggregated.Clone: TDtoPersonAggregated;
begin
  Result := TDtoPersonAggregated.Create(fPerson, fExistingAddressId, fAvailableAddresses);

  Result.VersionInfoBaseData.Assign(fVersionInfoBaseData);
  Result.VersionInfoMenberOfs.Assign(fVersionInfoMenberOfs);
  Result.AddressId := fAddressId;
  Result.CreateNewAddress := fCreateNewAddress;
  Result.NewAddressStreet := fNewAddressStreet;
  Result.NewAddressPostalcode := fNewAddressPostalcode;
  Result.NewAddressCity := fNewAddressCity;

  Result.MembershipNoMembership := fMembershipNoMembership;
  Result.MembershipId := fMembershipId;
  Result.MembershipActive := fMembershipActive;
  Result.MembershipNumber := fMembershipNumber;
  Result.MembershipBeginDate := fMembershipBeginDate;
  Result.MembershipEndDate := fMembershipEndDate;
  Result.MembershipEndDateText := fMembershipEndDateText;
  Result.MembershipEndReason := fMembershipEndReason;
end;

function TDtoPersonAggregated.GetAddressIndex: Integer;
begin
  Result := fAvailableAddresses.Data.Mapper.GetIndex(fAddressId);
end;

procedure TDtoPersonAggregated.SetAddressIndex(const aValue: Integer);
begin
  fAddressId := fAvailableAddresses.Data.Mapper.GetKey(aValue);
end;

function TDtoPersonAggregated.GetDtoClubmembership: TDtoClubmembership;
begin
  Result := default(TDtoClubmembership);
  Result.Id := fMembershipId;
  Result.PersonId := fPerson.NameId.Id;
  Result.Active := fMembershipActive;
  Result.Number := fMembershipNumber;
  Result.Startdate := fMembershipBeginDate;
  Result.Enddate := fMembershipEndDate;
  Result.EnddateStr := fMembershipEndDateText;
  Result.Endreason := fMembershipEndReason;
end;

procedure TDtoPersonAggregated.UpdateExistingAddressId;
begin
  fExistingAddressId := fAddressId;
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
