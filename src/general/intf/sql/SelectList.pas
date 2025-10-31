unit SelectList;

interface

uses SelectRecord, SqlConnection;

type
  ISelectList<T> = interface(ISelectRecord<T>)
    ['{9E4679D5-7F2C-4DB7-B922-7A6C8B2272C5}']
    function GetSelectListSQL: string;
  end;

  IParameterizedSelectList<P> = interface
    ['{E26B1348-8024-464F-A815-DC00FDDEA08F}']
    function GetParameterizedSelectQuery(const aConnection: ISqlConnection;
      const aListParams: P): ISqlPreparedQuery;
  end;

implementation

end.
