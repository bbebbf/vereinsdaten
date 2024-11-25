unit CrudTableConfig;

interface

uses CrudAccessor;

type
  ICrudTableConfig<TRecord: record> = interface
    ['{E9152F7A-7955-4227-8182-B34F85DC9A69}']
    function GetTablename: string;
    procedure SetValues(const aRecord: TRecord; const aAccessor: TCrudAccessorBase);
    procedure SetValuesForDelete(const aRecord: TRecord; const aAccessor: TCrudAccessorDelete);
  end;

implementation

end.
