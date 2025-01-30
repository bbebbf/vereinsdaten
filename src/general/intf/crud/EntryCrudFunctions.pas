unit EntryCrudFunctions;

interface

uses Transaction;

type
  IEntryCrudFunctions<T> = interface
    ['{63758CD8-948B-444B-A1D7-B9EA658F6024}']
    procedure LoadEntry(const aEntry: T);
    procedure SaveEntry(const aEntry: T; const aTransaction: ITransaction);
    procedure DeleteEntry(const aEntry: T; const aTransaction: ITransaction);
  end;

implementation

end.
