unit GenericConverter;

interface

uses System.SysUtils, ValueConverter;

type
  TGenericConverter<S, T> = class(TInterfacedBase, IValueConverter<S, T>)
  end;


implementation

end.
