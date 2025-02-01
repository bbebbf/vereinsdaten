unit MemberOfBusinessIntf;

interface

uses ListCrudCommands, CrudCommands, Vdm.Versioning.Types, EntryCrudFunctions, DtoMemberAggregated, DtoPersonAggregated;

type
  IPersonMemberOfsCrudFunction = interface(IEntriesCrudFunctions<TDtoMemberAggregated>)
    ['{B30D3E07-E3AD-41AC-B270-10D9542D90A5}']
    procedure SetCurrentPersonEntry(const aPersonEntry: TDtoPersonAggregated);
    function GetVersionConflictDetected: Boolean;
    function GetConflictedVersionEntry: TVersionInfoEntry;
    property VersionConflictDetected: Boolean read GetVersionConflictDetected;
    property ConflictedVersionEntry: TVersionInfoEntry read GetConflictedVersionEntry;
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
    property ShowInactiveMemberOfs: Boolean read GetShowInactiveMemberOfs write SetShowInactiveMemberOfs;
  end;


implementation

end.
