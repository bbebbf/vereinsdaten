unit DtoMemberAggregated;

interface

uses System.Classes, DtoMember, MemberOfConfigIntf, KeyIndexStrings, Vdm.Versioning.Types;

type
  TDtoMemberAggregated = class
  strict private
    fMember: TDtoMember;
    fMemberOfConfigIntf: IMemberOfConfigIntf;
    fAvailableRoles: TKeyIndexStrings;
    fVersionInfoPersonMenberOf: TVersionInfoEntry;
    function GetAvailableDetailItems: TKeyIndexStrings;
    function GetRoleIndex: Integer;
    function GetDetailItemIndex: Integer;
    procedure SetRoleIndex(const aValue: Integer);
    procedure SetDetailItemIndex(const aValue: Integer);
    function GetVersionInfoPersonMenberOf: TVersionInfoEntry;
  public
    constructor Create(const aMemberOfConfigIntf: IMemberOfConfigIntf; const aAvailableRoles: TKeyIndexStrings); overload;
    constructor Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
      const aAvailableRoles: TKeyIndexStrings; const aMember: TDtoMember); overload;
    destructor Destroy; override;
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
    property AvailableDetailItems: TKeyIndexStrings read GetAvailableDetailItems;
    property AvailableRoles: TKeyIndexStrings read fAvailableRoles;
    property VersionInfoPersonMenberOf: TVersionInfoEntry read GetVersionInfoPersonMenberOf;
  end;

implementation

{ TDtoMemberAggregated }

constructor TDtoMemberAggregated.Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
  const aAvailableRoles: TKeyIndexStrings);
begin
  inherited Create;
  fMemberOfConfigIntf := aMemberOfConfigIntf;
  fAvailableRoles := aAvailableRoles;
  fMember := default(TDtoMember);
end;

constructor TDtoMemberAggregated.Create(const aMemberOfConfigIntf: IMemberOfConfigIntf;
  const aAvailableRoles: TKeyIndexStrings; const aMember: TDtoMember);
begin
  inherited Create;
  fMemberOfConfigIntf := aMemberOfConfigIntf;
  fAvailableRoles := aAvailableRoles;
  fMember := aMember;
end;

destructor TDtoMemberAggregated.Destroy;
begin
  fVersionInfoPersonMenberOf.Free;
  inherited;
end;

function TDtoMemberAggregated.GetRoleIndex: Integer;
begin
  Result := fAvailableRoles.Data.Mapper.GetIndex(fMember.RoleId);
end;

function TDtoMemberAggregated.GetVersionInfoPersonMenberOf: TVersionInfoEntry;
begin
  if not Assigned(fVersionInfoPersonMenberOf) then
    fVersionInfoPersonMenberOf := TVersionInfoEntry.Create;
  Result := fVersionInfoPersonMenberOf;
end;

function TDtoMemberAggregated.GetAvailableDetailItems: TKeyIndexStrings;
begin
  Result := fMemberOfConfigIntf.GetDetailItemMapper;
end;

function TDtoMemberAggregated.GetDetailItemIndex: Integer;
begin
  Result := fMemberOfConfigIntf.GetDetailItemMapper.Data.Mapper.GetIndex(fMemberOfConfigIntf.GetDetailItemIdFromMember(fMember));
end;

procedure TDtoMemberAggregated.SetRoleIndex(const aValue: Integer);
begin
  fMember.RoleId := fAvailableRoles.Data.Mapper.GetKey(aValue);
end;

procedure TDtoMemberAggregated.SetDetailItemIndex(const aValue: Integer);
begin
  fMemberOfConfigIntf.SetDetailItemIdToMember(fMemberOfConfigIntf.GetDetailItemMapper.Data.Mapper.GetKey(aValue), fMember);
end;

procedure TDtoMemberAggregated.UpdateByDtoMember(const aMember: TDtoMember);
begin
  fMember := aMember;
end;

end.
