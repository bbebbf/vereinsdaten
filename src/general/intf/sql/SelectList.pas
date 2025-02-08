unit SelectList;

interface

uses SelectRecord;

type
  ISelectList<T> = interface(ISelectRecord<T>)
    ['{9E4679D5-7F2C-4DB7-B922-7A6C8B2272C5}']
    function GetSelectListSQL: string;
  end;

  ISelectListActiveEntries<T> = interface(ISelectRecord<T>)
    ['{937061B8-C6EC-42EA-869D-BECBAA859AC7}']
    function GetSelectListActiveEntriesSQL: string;
  end;

implementation

end.
