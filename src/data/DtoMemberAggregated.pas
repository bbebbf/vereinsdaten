unit DtoMemberAggregated;

interface

uses System.Classes, DtoMember, MemberOfConfigIntf, KeyIndexStrings, Vdm.Versioning.Types;

type
  TDtoMemberAggregated = class
  strict private
    fMember: TDtoMember;
    fMemberOfConfigIntf: IMemberOfConfigIntf;
    fAvailableRoles: TKeyIndexStrings;
    fVersionInfoPersonMemberOf: TVersionInfoEntry;
    function GetAvailableDetailItems: TActiveKeyIndexStringsLoader;
    function GetRoleIndex: Integer;
    function GetDetailItemId: UInt32;
    procedure SetRoleIndex(const aValue: Integer);
    procedure SetDetailItemId(const aValue: UInt32);
    function GetVersionInfoPersonMemberOf: TVersionInfoEntry;
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
    property DetailItemId: UInt32 read GetDetailItemId write SetDetailItemId;
    property RoleIndex: Integer read GetRoleIndex write SetRoleIndex;
    property AvailableDetailItems: TActiveKeyIndexStringsLoader read GetAvailableDetailItems;
    property AvailableRoles: TKeyIndexStrings read fAvailableRoles;
    property VersionInfoPersonMemberOf: TVersionInfoEntry read GetVersionInfoPersonMemberOf;
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
  fVersionInfoPersonMemberOf.Free;
  inherited;
end;

function TDtoMemberAggregated.GetRoleIndex: Integer;
begin
  Result := fAvailableRoles.Data.Mapper.GetIndex(fMember.RoleId);
end;

function TDtoMemberAggregated.GetVersionInfoPersonMemberOf: TVersionInfoEntry;
begin
  if not Assigned(fVersionInfoPersonMemberOf) then
    fVersionInfoPersonMemberOf := TVersionInfoEntry.Create;
  Result := fVersionInfoPersonMemberOf;
end;

function TDtoMemberAggregated.GetAvailableDetailItems: TActiveKeyIndexStringsLoader;
begin
  Result := fMemberOfConfigIntf.GetDetailItemMapper;
end;

function TDtoMemberAggregated.GetDetailItemId: UInt32;
begin
  Result := fMemberOfConfigIntf.GetDetailItemIdFromMember(fMember);
end;

procedure TDtoMemberAggregated.SetRoleIndex(const aValue: Integer);
begin
  fMember.RoleId := fAvailableRoles.Data.Mapper.GetKey(aValue);
end;

procedure TDtoMemberAggregated.SetDetailItemId(const aValue: UInt32);
begin
  fMemberOfConfigIntf.SetDetailItemIdToMember(aValue, fMember);
end;

procedure TDtoMemberAggregated.UpdateByDtoMember(const aMember: TDtoMember);
begin
  fMember := aMember;
end;

end.
