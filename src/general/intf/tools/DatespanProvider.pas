unit DatespanProvider;

interface

uses Nullable;

type
  TDatespanKind = (Undefined, FromOnly, ToOnly, DateSpan);
  TDatespanKinds = set of TDatespanKind;

  IDatespanProvider = interface
    ['{83223D05-BC49-4D6D-B8E2-07EC36866FAD}']
    function ProvideDatespan: Boolean;
    function GetTitle: string;
    procedure SetTitle(const aTitle: string);
    function GetAllowedKinds: TDatespanKinds;
    procedure SetAllowedKinds(const aKinds: TDatespanKinds);
    function GetFromDate: INullable<TDate>;
    procedure SetFromDate(const aFromDate: TDate);
    function GetToDate: INullable<TDate>;
    procedure SetToDate(const aToDate: TDate);
    property Title: string read GetTitle write SetTitle;
    property AllowedKinds: TDatespanKinds read GetAllowedKinds write SetAllowedKinds;
    property FromDate: INullable<TDate> read GetFromDate;
    property ToDate: INullable<TDate> read GetToDate;
  end;

implementation

end.
