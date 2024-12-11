unit ListEnumerator;

interface

type
  IListEnumerator<T> = interface
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: T);
    procedure ListEnumEnd;
  end;

implementation

end.
