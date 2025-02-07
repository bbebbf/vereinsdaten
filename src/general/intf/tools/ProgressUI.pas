unit ProgressUI;

interface

type
  IProgressUI = interface
    ['{AE7C8390-6947-41DB-9BFC-CD44675CB0B6}']
    procedure Show;
    procedure Hide;
    function GetPrimaryText: string;
    procedure SetPrimaryText(const aValue: string);
    function GetSecondaryText: string;
    procedure SetSecondaryText(const aValue: string);
    function GetDoneWork: Integer;
    procedure SetDoneWork(const aValue: Integer);
    function GetMaxmimalWork: Integer;
    procedure SetMaximalWork(const aValue: Integer);

    property PrimaryText: string read GetPrimaryText write SetPrimaryText;
    property SecondaryText: string read GetSecondaryText write SetSecondaryText;
    property MaximalWork: Integer read GetMaxmimalWork write SetMaximalWork;
    property DoneWork: Integer read GetDoneWork write SetDoneWork;
  end;

implementation

end.
