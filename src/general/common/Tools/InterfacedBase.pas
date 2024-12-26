unit InterfacedBase;

interface

type
  IInterfacedBase = interface
    ['{EE734D37-5CE7-4BD8-B638-DF5C2CF11555}']
    function GetRefCount: Integer;
    property RefCount: Integer read GetRefCount;
  end;

  TInterfacedBase = class(TInterfacedObject, IInterfacedBase)
  public
    destructor Destroy; override;
  end;

implementation

{ TInterfacedBase }

destructor TInterfacedBase.Destroy;
begin

  inherited;
end;

end.
