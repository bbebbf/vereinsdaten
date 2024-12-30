unit DtoAddressAggregated;

interface

uses System.Generics.Collections, DtoPersonNameId, DtoAddress, Vdm.Versioning.Types;

type
  TDtoAddressAggregatedPersonMemberOf = record
    PersonNameId: TDtoPersonNameId;
    PersonActive: Boolean;
  end;

  TDtoAddressAggregated = class
  strict private
    fAddress: TDtoAddress;
    fVersionInfo: TVersionInfoEntry;
    fMemberOfList: TList<TDtoAddressAggregatedPersonMemberOf>;
  public
    constructor Create(const aAddress: TDtoAddress);
    destructor Destroy; override;
    function ToString: string; override;
    procedure UpdateByDtoAddress(const aAddress: TDtoAddress);
    property Address: TDtoAddress read fAddress;
    property VersionInfo: TVersionInfoEntry read fVersionInfo;
    property Id: UInt32 read fAddress.Id write fAddress.Id;
    property Street: string read fAddress.Street write fAddress.Street;
    property Postalcode: string read fAddress.Postalcode write fAddress.Postalcode;
    property City: string read fAddress.City write fAddress.City;
    property MemberOfList: TList<TDtoAddressAggregatedPersonMemberOf> read fMemberOfList;
  end;

implementation

{ TDtoAddressAggregated }

constructor TDtoAddressAggregated.Create(const aAddress: TDtoAddress);
begin
  inherited Create;
  fAddress := aAddress;
  fVersionInfo := TVersionInfoEntry.Create;
  fMemberOfList := TList<TDtoAddressAggregatedPersonMemberOf>.Create;
end;

destructor TDtoAddressAggregated.Destroy;
begin
  fMemberOfList.Free;
  fVersionInfo.Free;
  inherited;
end;

function TDtoAddressAggregated.ToString: string;
begin
  Result := fAddress.ToString;
end;

procedure TDtoAddressAggregated.UpdateByDtoAddress(const aAddress: TDtoAddress);
begin
  fAddress := aAddress;
end;

end.
