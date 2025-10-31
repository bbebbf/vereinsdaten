unit EntryCrudConfig;

interface

uses SqlConnection, CrudCommands;

type
  IEntryCrudConfig<TEntry; TListEntry; TId, TListFilter: record> = interface
    ['{C5610CB4-146B-4494-B061-082C5F259563}']
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TListEntry;
    function IsEntryValidForList(const aEntry: TListEntry; const aListFilter: TListFilter): Boolean;
    function IsEntryValidForSaving(const aEntry: TEntry): Boolean;
    procedure DestroyEntry(var aEntry: TEntry);
    procedure DestroyListEntry(var aEntry: TListEntry);
    procedure StartNewEntry;
    procedure NewEntrySaved(const aEntry: TEntry);
    function GetIdFromEntry(const aEntry: TEntry): TId;
    function TryLoadEntry(const aId: TId; out aEntry: TEntry): Boolean;
    function CreateEntry: TEntry;
    function CloneEntry(const aEntry: TEntry): TEntry;
    function IsEntryUndefined(const aEntry: TEntry): Boolean;
    function SaveEntry(var aEntry: TEntry): TCrudSaveResult;
    function DeleteEntry(const aId: TId): Boolean;
    function GetEntryTitle(const aPlural: Boolean): string;
  end;

  IEntryCrudConfigParameterizedList<TListFilter: record> = interface
    ['{1EC17506-5FBA-44BD-896F-04471DA3A078}']
    function GetParameterizedListSqlQuery(const aListFilter: TListFilter): ISqlPreparedQuery;
  end;

implementation

end.
