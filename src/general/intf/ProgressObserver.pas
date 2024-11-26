unit ProgressObserver;

interface

type
  IProgressObserver = interface
    ['{BE3F280D-F437-4ECC-88B2-C49F8284C15C}']
    procedure ProgressBegin(const aWorkCount: Integer; const aSteptextAvailable: Boolean; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer; const aStepText: string = '');
    procedure ProgressEnd;
  end;

implementation

end.
