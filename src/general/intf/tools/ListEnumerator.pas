unit ListEnumerator;

interface

type
  IListEnumerator<T> = interface
    ['{EAD20A73-7879-423D-B05F-199EA328C50D}']
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: T);
    procedure ListEnumEnd;
  end;

implementation

end.
