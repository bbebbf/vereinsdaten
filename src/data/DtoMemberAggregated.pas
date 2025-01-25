unit DtoMemberAggregated;

interface

uses System.Classes, DtoMember, MemberOfConfigIntf, KeyIndexStrings;

type
  TDtoMemberAggregated = class
  strict private
    fMember: TDtoMember;
    fMemberOfConfigIntf: IMemberOfConfigIntf;
    fAvailableDetailItems: TKeyIndexStrings;
    fAvailableRoles: TKeyIndexStrings;
    function GetRoleIndex: Integer;
    function GetDetailItemIndex: Integer;
    procedure SetRoleIndex(const aValue: Integer);
    procedure SetDetailItemIndex(const aValue: Integer);
  public
    constructor Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
      const aAvailableDetailItems, aAvailableRoles: TKeyIndexStrings); overload;
    constructor Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
      const aAvailableDetailItems, aAvailableRoles: TKeyIndexStrings; const aMember: TDtoMember); overload;
    procedure UpdateByDtoMember(const aMember: TDtoMember);
    property Member: TDtoMember read fMember;
    property Id: UInt32 read fMember.Id write fMember.Id;
    property PersonId: UInt32 read fMember.PersonId write fMember.PersonId;
    property UnitId: UInt32 read fMember.UnitId write fMember.UnitId;
    property RoleId: UInt32 read fMember.RoleId write fMember.RoleId;
    property Active: Boolean read fMember.Active write fMember.Active;
    property ActiveSince: TDate read fMember.ActiveSince write fMember.ActiveSince;
    property ActiveUntil: TDate read fMember.ActiveUntil write fMember.ActiveUntil;
    property DetailItemIndex: Integer read GetDetailItemIndex write SetDetailItemIndex;
    property RoleIndex: Integer read GetRoleIndex write SetRoleIndex;
    property AvailableDetailItems: TKeyIndexStrings read fAvailableDetailItems;
    property AvailableRoles: TKeyIndexStrings read fAvailableRoles;
  end;

implementation

{ TDtoMemberAggregated }

constructor TDtoMemberAggregated.Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
  const aAvailableDetailItems, aAvailableRoles: TKeyIndexStrings);
begin
  inherited Create;
  fMemberOfConfigIntf := aMemberOfConfigIntf;
  fAvailableDetailItems := aAvailableDetailItems;
  fAvailableRoles := aAvailableRoles;
  fMember := default(TDtoMember);
end;

constructor TDtoMemberAggregated.Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
  const aAvailableDetailItems, aAvailableRoles: TKeyIndexStrings; const aMember: TDtoMember);
begin
  inherited Create;
  fMemberOfConfigIntf := aMemberOfConfigIntf;
  fAvailableDetailItems := aAvailableDetailItems;
  fAvailableRoles := aAvailableRoles;
  fMember := aMember;
end;

function TDtoMemberAggregated.GetRoleIndex: Integer;
begin
  Result := fAvailableRoles.Data.Mapper.GetIndex(fMember.RoleId);
end;

function TDtoMemberAggregated.GetDetailItemIndex: Integer;
begin
  Result := fAvailableDetailItems.Data.Mapper.GetIndex(fMemberOfConfigIntf.GetDetailItemIdFromMember(fMember));
end;

procedure TDtoMemberAggregated.SetRoleIndex(const aValue: Integer);
begin
  fMember.RoleId := fAvailableRoles.Data.Mapper.GetKey(aValue);
end;

procedure TDtoMemberAggregated.SetDetailItemIndex(const aValue: Integer);
begin
  fMemberOfConfigIntf.SetDetailItemIdToMember(fAvailableDetailItems.Data.Mapper.GetKey(aValue), fMember);
end;

procedure TDtoMemberAggregated.UpdateByDtoMember(const aMember: TDtoMember);
begin
  fMember := aMember;
end;

end.
