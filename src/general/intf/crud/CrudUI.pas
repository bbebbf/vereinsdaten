unit CrudUI;

interface

uses System.Generics.Collections, CrudCommands, ListEnumerator;

type
  ICrudUI<TEntry; TRecordIdentity: record> = interface(IListEnumerator<TEntry>)
    ['{4A2A8AC7-F6C5-43AA-A099-6B969F6291BF}']
    procedure Initialize(const aCommands: ICrudCommands<TRecordIdentity>);
    procedure DeleteEntryFromUI(const aRecordIdentity: TRecordIdentity);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TEntry; const aAsNewEntry: Boolean);
    function GetEntryFromUI(var aEntry: TEntry): Boolean;
  end;

implementation

end.
