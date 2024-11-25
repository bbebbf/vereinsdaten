unit Transaction;

interface

type
  ITransaction = interface
    ['{7ED7E759-2F06-40BC-B7D3-7AA7458ABA8B}']
    procedure Commit;
    procedure Rollback;
  end;

implementation

end.
