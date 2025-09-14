unit ParamsProvider;

interface

type
  IParamsProvider<T> = interface
    ['{C37C09E4-207B-436A-8976-8F17C38C85B2}']
    procedure SetTargets(const aTargets: TArray<string>);
    function GetTargetIndex: Integer;
    function ProvideParams: Boolean;
    function GetParams(const aParams: T): T;
    procedure SetParams(const aParams: T);
    function ShouldBeExported(const aParams: T): Boolean;
  end;

implementation

end.
