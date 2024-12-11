unit SelectList;

interface

uses SelectRecord;

type
  ISelectList<T> = interface(ISelectRecord<T>)
    ['{9E4679D5-7F2C-4DB7-B922-7A6C8B2272C5}']
    function GetSelectListSQL: string;
  end;

implementation

end.
