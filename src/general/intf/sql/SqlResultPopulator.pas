unit SqlResultPopulator;

interface

uses SqlConnection;

type
  ISqlResultPopulator<T> = interface
    ['{3ABFBF01-2D37-4A13-B4E0-D48EF44653EF}']
    procedure PopulateEntry(const aSqlResult: ISqlResult; var aEntry: T);
  end;

implementation

end.
