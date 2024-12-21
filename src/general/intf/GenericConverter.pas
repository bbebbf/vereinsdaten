unit GenericConverter;

interface

type
  IGenericConverter<S, D> = interface
    ['{DDB8E1EF-3355-4BCE-BD10-621DCE6D36D9}']
    function GetDestinationFromSource(const aValue: S): D;
    function GetSourceFromDestination(const aValue: D): S;
  end;

  IGenericCreateConverter<S, D> = interface( IGenericConverter<S, D>)
    ['{2EDE5238-8DF9-4257-9BC3-BB0A2FB50C37}']
    function GetDestinationFromSource(const aValue: S): D;
  end;

implementation

end.
