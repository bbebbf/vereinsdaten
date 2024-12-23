unit MasterdataBusinessIntf;

interface

uses CrudCommands;

type
  IMasterdataBusinessIntf<TEntry: class; TId: record> = interface(ICrudCommands<TId>)
    ['{4425470D-EBA3-45AC-B789-F68E94DA48F8}']
  end;

implementation

end.
