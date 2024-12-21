unit LazyLoader;

interface

type
  TLazyLoadDataFunc<T> = reference to function(var aData: T): Boolean;

  TLazyLoader<T> = class
  strict private
    fLoadFunc: TLazyLoadDataFunc<T>;
    fData: T;
    fLoaded: Boolean;
    function GetData: T;
  strict protected
    procedure InvalidateData(var aData: T); virtual;
    function DoLazyLoad(var aData: T): Boolean; virtual;
  public
    constructor Create(const aLoadFunc: TLazyLoadDataFunc<T>);
    destructor Destroy; override;
    procedure Invalidate;
    property Data: T read GetData;
  end;

  TLazyObjectLoader<T: class> = class(TLazyLoader<T>)
  strict protected
    procedure InvalidateData(var aData: T); override;
  public
  end;

implementation

uses System.SysUtils;

{ TLazyLoader<T> }

constructor TLazyLoader<T>.Create(const aLoadFunc: TLazyLoadDataFunc<T>);
begin
  inherited Create;
  fLoadFunc := aLoadFunc;
end;

destructor TLazyLoader<T>.Destroy;
begin
  Invalidate;
  inherited;
end;

function TLazyLoader<T>.GetData: T;
begin
  if not fLoaded then
    fLoaded := DoLazyLoad(fData);
  Result := fData;
end;

procedure TLazyLoader<T>.Invalidate;
begin
  fLoaded := False;
  InvalidateData(fData);
end;

procedure TLazyLoader<T>.InvalidateData(var aData: T);
begin

end;

function TLazyLoader<T>.DoLazyLoad(var aData: T): Boolean;
begin
  Result := False;
  if Assigned(fLoadFunc) then
    Result := fLoadFunc(aData);
end;

{ TLazyObjectLoader<T> }

procedure TLazyObjectLoader<T>.InvalidateData(var aData: T);
begin
  inherited;
  FreeAndNil(aData);
end;

end.
