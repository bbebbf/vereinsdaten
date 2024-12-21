unit ValueConverter;

interface

type
  IValueConverter<S, T> = interface
    ['{AC96CBB0-29B1-46B9-8897-CFC50EECC270}']
    procedure Convert(const aValue: S; var aTarget: T);
    procedure ConvertBack(const aValue: T; var aTarget: S);
  end;

implementation

end.
