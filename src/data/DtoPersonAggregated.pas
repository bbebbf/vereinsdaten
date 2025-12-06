unit DtoPersonAggregated;

interface

uses DtoPerson, DtoClubmembership, KeyIndexStrings, Vdm.Versioning.Types, SimpleDate, Nullable;

type
  TDtoPersonAggregated = class
  strict private
    fPerson: TDtoPerson;
    fVersionInfoBaseData: TVersionInfoEntry;
    fVersionInfoMemberOfs: TVersionInfoEntry;
    fExistingAddressId: UInt32;
    fAddressId: UInt32;
    fAvailableAddresses: TActiveKeyIndexStringsLoader;
    fCreateNewAddress: Boolean;
    fNewAddressStreet: string;
    fNewAddressPostalcode: string;
    fNewAddressCity: string;
    fMembershipNoMembership: Boolean;
    fMembershipId: UInt32;
    fMembershipActive: Boolean;
    fMembershipNumber: UInt16;
    fMembershipBeginDate: INullable<TDate>;
    fMembershipEndDate: INullable<TDate>;
    fMembershipEndDateText: string;
    fMembershipEndReason: string;
  public
    constructor Create(const aPerson: TDtoPerson; const aExistingAddressId: UInt32;
      const aAvailableAddresses: TActiveKeyIndexStringsLoader);
    destructor Destroy; override;
    function Clone: TDtoPersonAggregated;
    function GetDtoClubmembership: TDtoClubmembership;
    procedure SetDtoClubmembership(const aValue: TDtoClubmembership);
    procedure UpdateExistingAddressId;
    property Person: TDtoPerson read fPerson;
    property VersionInfoBaseData: TVersionInfoEntry read fVersionInfoBaseData;
    property VersionInfoMemberOfs: TVersionInfoEntry read fVersionInfoMemberOfs;
    property Id: UInt32 read fPerson.NameId.Id write fPerson.NameId.Id;
    property Firstname: string read fPerson.NameId.Firstname write fPerson.NameId.Firstname;
    property NameAddition: string read fPerson.NameId.NameAddition write fPerson.NameId.NameAddition;
    property Lastname: string read fPerson.NameId.Lastname write fPerson.NameId.Lastname;
    property Active: Boolean read fPerson.Active write fPerson.Active;
    property &External: Boolean read fPerson.External write fPerson.External;
    property Birthday: INullable<TSimpleDate> read fPerson.Birthday write fPerson.Birthday;
    property OnBirthdayList: Boolean read fPerson.OnBirthdayList write fPerson.OnBirthdayList;
    property Emailaddress: string read fPerson.Emailaddress write fPerson.Emailaddress;
    property Phonenumber: string read fPerson.Phonenumber write fPerson.Phonenumber;
    property PhonePriority: Boolean read fPerson.PhonePriority write fPerson.PhonePriority;

    property ExistingAddressId: UInt32 read fExistingAddressId;
    property AddressId: UInt32 read fAddressId write fAddressId;
    property AvailableAddresses: TActiveKeyIndexStringsLoader read fAvailableAddresses;
    property CreateNewAddress: Boolean read fCreateNewAddress write fCreateNewAddress;
    property NewAddressStreet: string read fNewAddressStreet write fNewAddressStreet;
    property NewAddressPostalcode: string read fNewAddressPostalcode write fNewAddressPostalcode;
    property NewAddressCity: string read fNewAddressCity write fNewAddressCity;

    property MembershipNoMembership: Boolean read fMembershipNoMembership write fMembershipNoMembership;
    property MembershipId: UInt32 read fMembershipId write fMembershipId;
    property MembershipActive: Boolean read fMembershipActive write fMembershipActive;
    property MembershipNumber: UInt16 read fMembershipNumber write fMembershipNumber;
    property MembershipBeginDate: INullable<TDate> read fMembershipBeginDate;
    property MembershipEndDate: INullable<TDate> read fMembershipEndDate;
    property MembershipEndDateText: string read fMembershipEndDateText write fMembershipEndDateText;
    property MembershipEndReason: string read fMembershipEndReason write fMembershipEndReason;
  end;

implementation

{ TDtoPersonAggregated }

constructor TDtoPersonAggregated.Create(const aPerson: TDtoPerson; const aExistingAddressId: UInt32;
  const aAvailableAddresses: TActiveKeyIndexStringsLoader);
begin
  inherited Create;
  fVersionInfoBaseData := TVersionInfoEntry.Create;
  fVersionInfoMemberOfs := TVersionInfoEntry.Create;
  fPerson := aPerson;
  fExistingAddressId := aExistingAddressId;
  fAvailableAddresses := aAvailableAddresses;
  fMembershipBeginDate := TNullable<TDate>.New;
  fMembershipEndDate := TNullable<TDate>.New;
end;

destructor TDtoPersonAggregated.Destroy;
begin
  fVersionInfoMemberOfs.Free;
  fVersionInfoBaseData.Free;
  inherited;
end;

function TDtoPersonAggregated.Clone: TDtoPersonAggregated;
begin
  Result := TDtoPersonAggregated.Create(fPerson, fExistingAddressId, fAvailableAddresses);

  Result.VersionInfoBaseData.Assign(fVersionInfoBaseData);
  Result.VersionInfoMemberOfs.Assign(fVersionInfoMemberOfs);
  Result.AddressId := fAddressId;
  Result.CreateNewAddress := fCreateNewAddress;
  Result.NewAddressStreet := fNewAddressStreet;
  Result.NewAddressPostalcode := fNewAddressPostalcode;
  Result.NewAddressCity := fNewAddressCity;

  Result.MembershipNoMembership := fMembershipNoMembership;
  Result.MembershipId := fMembershipId;
  Result.MembershipActive := fMembershipActive;
  Result.MembershipNumber := fMembershipNumber;
  Result.MembershipBeginDate.Assign(fMembershipBeginDate);
  Result.MembershipEndDate.Assign(fMembershipEndDate);
  Result.MembershipEndDateText := fMembershipEndDateText;
  Result.MembershipEndReason := fMembershipEndReason;
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
