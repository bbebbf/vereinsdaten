unit MemberOfBusinessIntf;

interface

uses ListCrudCommands, CrudCommands, Vdm.Versioning.Types, EntriesCrudEvents, DtoMemberAggregated, DtoPersonAggregated;

type
  IMemberOfsVersioningCrudEvents = interface(IEntriesCrudEvents<TDtoMemberAggregated>)
    ['{513D561B-D237-4BB0-9AF6-F118BF2C1037}']
    function GetVersionConflictDetected: Boolean;
    function GetConflictedVersionEntry: TVersionInfoEntry;
    property VersionConflictDetected: Boolean read GetVersionConflictDetected;
    property ConflictedVersionEntry: TVersionInfoEntry read GetConflictedVersionEntry;
  end;

  IPersonMemberOfsCrudEvents = interface(IMemberOfsVersioningCrudEvents)
    ['{58B7BF5B-8CD4-4016-897C-D1DB36F90380}']
    procedure SetCurrentPersonEntry(const aPersonEntry: TDtoPersonAggregated);
  end;

  IMemberOfBusinessIntf = interface
    ['{6BF5D206-C946-4FDC-802C-70FD1B652F04}']
    procedure Initialize;
    procedure LoadMemberOfs(const aMasterId: UInt32);
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);
    function CreateNewEntry: TListEntry<TDtoMemberAggregated>;
    procedure AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
    procedure ReloadEntries;
    function SaveEntries(const aDeleteEntryFromUICallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>):
      TCrudSaveResult;
    procedure ClearDetailItemCache;
    procedure ClearRoleCache;
    function GetDetailItemTitle: string;
    function GetShowVersionInfoInMemberListview: Boolean;
    property ShowInactiveMemberOfs: Boolean read GetShowInactiveMemberOfs write SetShowInactiveMemberOfs;
  end;


implementation

end.
