unit DtoMemberAggregated;

interface

uses System.Classes, DtoMember, KeyIndexStrings;

type
  TDtoMemberAggregated = class
  strict private
    fMember: TDtoMember;
    fAvailableUnits: TKeyIndexStrings;
    fAvailableRoles: TKeyIndexStrings;
    function GetRoleIndex: Integer;
    function GetUnitIndex: Integer;
    procedure SetRoleIndex(const aValue: Integer);
    procedure SetUnitIndex(const aValue: Integer);
  public
    constructor Create(const aAvailableUnits, aAvailableRoles: TKeyIndexStrings); overload;
    constructor Create(const aAvailableUnits, aAvailableRoles: TKeyIndexStrings; const aMember: TDtoMember); overload;
    procedure UpdateByDtoMember(const aMember: TDtoMember);
    property Member: TDtoMember read fMember;
    property Id: UInt32 read fMember.Id write fMember.Id;
    property PersonId: UInt32 read fMember.PersonId write fMember.PersonId;
    property UnitId: UInt32 read fMember.UnitId write fMember.UnitId;
    property RoleId: UInt32 read fMember.RoleId write fMember.RoleId;
    property Active: Boolean read fMember.Active write fMember.Active;
    property ActiveSince: TDate read fMember.ActiveSince write fMember.ActiveSince;
    property ActiveUntil: TDate read fMember.ActiveUntil write fMember.ActiveUntil;
    property UnitIndex: Integer read GetUnitIndex write SetUnitIndex;
    property RoleIndex: Integer read GetRoleIndex write SetRoleIndex;
    property AvailableUnits: TKeyIndexStrings read fAvailableUnits;
    property AvailableRoles: TKeyIndexStrings read fAvailableRoles;
  end;

implementation

{ TDtoMemberAggregated }

constructor TDtoMemberAggregated.Create(const aAvailableUnits, aAvailableRoles: TKeyIndexStrings);
begin
  inherited Create;
  fAvailableUnits := aAvailableUnits;
  fAvailableRoles := aAvailableRoles;
  fMember := default(TDtoMember);
end;

constructor TDtoMemberAggregated.Create(const aAvailableUnits, aAvailableRoles: TKeyIndexStrings;
  const aMember: TDtoMember);
begin
  inherited Create;
  fAvailableUnits := aAvailableUnits;
  fAvailableRoles := aAvailableRoles;
  fMember := aMember;
end;

function TDtoMemberAggregated.GetRoleIndex: Integer;
begin
  Result := fAvailableRoles.Data.Mapper.GetIndex(fMember.RoleId);
end;

function TDtoMemberAggregated.GetUnitIndex: Integer;
begin
  Result := fAvailableUnits.Data.Mapper.GetIndex(fMember.UnitId);
end;

procedure TDtoMemberAggregated.SetRoleIndex(const aValue: Integer);
begin
  fMember.RoleId := fAvailableRoles.Data.Mapper.GetKey(aValue);
end;

procedure TDtoMemberAggregated.SetUnitIndex(const aValue: Integer);
begin
  fMember.UnitId := fAvailableUnits.Data.Mapper.GetKey(aValue);
end;

procedure TDtoMemberAggregated.UpdateByDtoMember(const aMember: TDtoMember);
begin
  fMember := aMember;
end;

end.
