unit EntryCrudFunctions;

interface

uses Transaction;

type
  IEntryCrudFunctions<T> = interface
    ['{63758CD8-948B-444B-A1D7-B9EA658F6024}']
    procedure LoadEntry(const aEntry: T; const aTransaction: ITransaction);
    procedure SaveEntry(const aEntry: T; const aTransaction: ITransaction);
    procedure DeleteEntry(const aEntry: T; const aTransaction: ITransaction);
  end;

  IEntriesCrudFunctions<T> = interface(IEntryCrudFunctions<T>)
    ['{A6441E2A-ED85-4ABA-B378-3CC7662F49B8}']
    procedure BeginLoadEntries(const aTransaction: ITransaction);
    procedure EndLoadEntries(const aTransaction: ITransaction);
    procedure BeginSaveEntries(const aTransaction: ITransaction);
    procedure EndSaveEntries(const aTransaction: ITransaction);
  end;

implementation

end.
