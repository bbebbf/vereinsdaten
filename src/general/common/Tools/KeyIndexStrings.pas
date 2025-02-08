unit KeyIndexStrings;

interface

uses System.Classes, LazyLoader, KeyIndexMapper;

type
  TKeyIndexStringsData = class
  strict private
    fStrings: TStrings;
    fMapper: TKeyIndexMapper<UInt32>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure AddMappedString(const aStringId: UInt32; const aStringValue: string);
    property Mapper: TKeyIndexMapper<UInt32> read fMapper;
    property Strings: TStrings read fStrings;
  end;

  TKeyIndexStrings = class(TLazyObjectLoader<TKeyIndexStringsData>);

implementation

uses System.SysUtils;

{ TKeyIndexStringsData }

constructor TKeyIndexStringsData.Create;
begin
  inherited Create;
  fMapper := TKeyIndexMapper<UInt32>.Create(0);
  fStrings := TStringList.Create;
end;

destructor TKeyIndexStringsData.Destroy;
begin
  fStrings.Free;
  fMapper.Free;
  inherited;
end;

procedure TKeyIndexStringsData.AddMappedString(const aStringId: UInt32; const aStringValue: string);
begin
  fMapper.Add(aStringId, fStrings.Add(aStringValue));
end;

procedure TKeyIndexStringsData.BeginUpdate;
begin
  fStrings.BeginUpdate;
end;

procedure TKeyIndexStringsData.EndUpdate;
begin
  fStrings.EndUpdate;
end;

end.
