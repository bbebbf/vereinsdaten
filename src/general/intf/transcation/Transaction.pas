unit Transaction;

interface

type
  ITransaction = interface
    ['{7ED7E759-2F06-40BC-B7D3-7AA7458ABA8B}']
    function GetActive: Boolean;
    function GetWasCommitted: Boolean;
    function GetWasRollbacked: Boolean;
    function Commit: Boolean;
    function Rollback: Boolean;
    property Active: Boolean read GetActive;
    property WasCommitted: Boolean read GetWasCommitted;
    property WasRollbacked: Boolean read GetWasRollbacked;
  end;

implementation

end.
