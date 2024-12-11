unit DtoMemberAggregated;

interface

uses DtoMember;

type
  TDtoMemberAggregated = class
  strict private
    fMember: TDtoMember;
    fUnitIndex: Integer;
    fRoleIndex: Integer;
  public
    constructor Create(const aMember: TDtoMember);
    property Member: TDtoMember read fMember;
    property Id: UInt32 read fMember.Id;
    property UnitIndex: Integer read fUnitIndex write fUnitIndex;
    property RoleIndex: Integer read fRoleIndex write fRoleIndex;
  end;

implementation

{ TDtoMemberAggregated }

constructor TDtoMemberAggregated.Create(const aMember: TDtoMember);
begin
  inherited Create;
  fMember := aMember;
end;

end.
