unit EntryCrudConfig;

interface

uses SqlConnection;

type
  IEntryCrudConfig<TEntry; TId: record> = interface
    ['{C5610CB4-146B-4494-B061-082C5F259563}']
    function GetListSqlResult: ISqlResult;
    function GetEntryFromListSqlResult(const aSqlResult: ISqlResult): TEntry;
    function IsEntryValidForList(const aEntry: TEntry): Boolean;
    function IsEntryValidForSaving(const aEntry: TEntry): Boolean;
    procedure DestroyEntry(var aEntry: TEntry);
    function TryLoadEntry(const aId: TId; out aEntry: TEntry): Boolean;
    function CreateEntry: TEntry;
    function CloneEntry(const aEntry: TEntry): TEntry;
    function IsEntryUndefined(const aEntry: TEntry): Boolean;
    function SaveEntry(var aEntry: TEntry): Boolean;
    function DeleteEntry(const aId: TId): Boolean;
  end;

implementation

end.
