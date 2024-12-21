unit KeyIndexStrings;

interface

uses System.Classes, LazyLoader, KeyIndexMapper;

type
  TKeyIndexStringsMapperRecord = record
    Strings: TStrings;
    Mapper: TKeyIndexMapper<UInt32>;
  end;

  TKeyIndexStrings = class(TLazyLoader<TKeyIndexStringsMapperRecord>)
  strict private
  strict protected
    procedure InvalidateData(var aData: TKeyIndexStringsMapperRecord); override;
  end;

implementation

uses System.SysUtils;

{ TKeyIndexStrings }

procedure TKeyIndexStrings.InvalidateData(var aData: TKeyIndexStringsMapperRecord);
begin
  inherited;
  FreeAndNil(aData.Strings);
  FreeAndNil(aData.Mapper);
end;

end.
