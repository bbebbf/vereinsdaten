unit MemberOfBusinessIntf;

interface

uses System.Classes, CrudCommands, DtoMemberAggregated;

type
  IMemberOfBusinessIntf = interface(ICrudCommands<TDtoMemberAggregated>)
    ['{6BF5D206-C946-4FDC-802C-70FD1B652F04}']
    procedure LoadAvailableUnits(const aStrings: TStrings);
    procedure LoadAvailableRoles(const aStrings: TStrings);
    procedure LoadPersonsMemberOfs(const aPersonId: UInt32);
    function GetUnitMapperIndex(const aUnitId: UInt32): Integer;
    function GetRoleMapperIndex(const aRoleId: UInt32): Integer;
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);
    property ShowInactiveMemberOfs: Boolean read GetShowInactiveMemberOfs write SetShowInactiveMemberOfs;
  end;


implementation

end.
