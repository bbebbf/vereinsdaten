unit GenericConverter;

interface

uses System.SysUtils, ValueConverter;

type
  TGenericConverter<S, T> = class(TInterfacedObject, IValueConverter<S, T>)
  end;


implementation

end.
