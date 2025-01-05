unit CrudUI;

interface

uses System.Generics.Collections, CrudCommands, ListEnumerator;

type
  TEntryToUIMode = (OnLoadCurrentEntry, OnUpdatedExistingEntry, OnCreatedNewEntry);

  ICrudUI<TEntry; TListEntry; TRecordIdentity, TListFilter: record> = interface(IListEnumerator<TListEntry>)
    ['{4A2A8AC7-F6C5-43AA-A099-6B969F6291BF}']
    procedure SetCrudCommands(const aCommands: ICrudCommands<TRecordIdentity, TListFilter>);
    procedure DeleteEntryFromUI(const aRecordIdentity: TRecordIdentity);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TEntry; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TEntry): Boolean;
  end;

implementation

end.
