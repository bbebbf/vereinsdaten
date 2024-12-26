unit MemberOfBusinessIntf;

interface

uses ListCrudCommands, DtoMemberAggregated;

type
  IMemberOfBusinessIntf = interface
    ['{6BF5D206-C946-4FDC-802C-70FD1B652F04}']
    procedure Initialize;
    procedure LoadPersonsMemberOfs(const aPersonId: UInt32);
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);
    function CreateNewEntry: TListEntry<TDtoMemberAggregated>;
    procedure AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
    procedure ReloadEntries;
    procedure SaveEntries(const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>);
    procedure ClearUnitCache;
    procedure ClearRoleCache;
    property ShowInactiveMemberOfs: Boolean read GetShowInactiveMemberOfs write SetShowInactiveMemberOfs;
  end;


implementation

end.
