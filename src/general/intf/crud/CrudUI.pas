unit CrudUI;

interface

uses System.Generics.Collections, CrudCommands, ListEnumerator;

type
  ICrudUI<TRecord; TRecordIdentity: record> = interface(IListEnumerator<TRecord>)
    ['{4A2A8AC7-F6C5-43AA-A099-6B969F6291BF}']
    procedure Initialize(const aCommands: ICrudCommands<TRecordIdentity>);
    procedure DeleteRecordfromUI(const aRecordIdentity: TRecordIdentity);
    procedure ClearRecordUI;
    procedure SetRecordToUI(const aRecord: TRecord; const aRecordAsNewEntry: Boolean);
    function GetRecordFromUI(var aRecord: TRecord): Boolean;
  end;

implementation

end.
