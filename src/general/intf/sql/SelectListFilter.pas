unit SelectListFilter;

interface

uses SqlConnection, SelectList;

type
  ISelectListFilter<T; F> = interface(ISelectList<T>)
    ['{1B48A254-60EF-49AA-8E57-7986F0BBEC10}']
    procedure SetSelectListSQLParameter(const aFilter: F; const aQuery: ISqlPreparedQuery);
  end;

implementation

end.
