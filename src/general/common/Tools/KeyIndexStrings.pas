unit KeyIndexStrings;

interface

uses System.Classes, System.Generics.Collections, LazyLoader, KeyIndexMapper;

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
    function GetStringById(const aStringId: UInt32; const aNotFoundStr: string = ''): string;
    property Mapper: TKeyIndexMapper<UInt32> read fMapper;
    property Strings: TStrings read fStrings;
  end;

  TActiveKeyIndexStringEntry = class
  public
    Id: UInt32;
    Title: string;
  end;

  TActiveKeyIndexStrings = class
  strict private
    fAllEntries: TObjectList<TActiveKeyIndexStringEntry>;
    fActiveEntries: TList<TActiveKeyIndexStringEntry>;
    function GetEntries(const aList: TList<TActiveKeyIndexStringEntry>): TKeyIndexStringsData;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddString(const aId: UInt32; const aActive: Boolean; const aTitle: string);
    function GetAllEntries: TKeyIndexStringsData;
    function GetActiveEntries: TKeyIndexStringsData;
  end;

  TKeyIndexStrings = class(TLazyObjectLoader<TKeyIndexStringsData>);
  TActiveKeyIndexStringsLoader = class(TLazyObjectLoader<TActiveKeyIndexStrings>);

implementation

uses System.SysUtils, StringTools;

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

function TKeyIndexStringsData.GetStringById(const aStringId: UInt32; const aNotFoundStr: string): string;
begin
  var lIndex: Integer;
  if not Mapper.TryGetIndex(aStringId, lIndex) then
    Exit(aNotFoundStr);
  Result := TStringTools.GetStringByIndex(Strings, lIndex, aNotFoundStr);
end;

{ TActiveKeyIndexStrings }

constructor TActiveKeyIndexStrings.Create;
begin
  inherited Create;
  fAllEntries := TObjectList<TActiveKeyIndexStringEntry>.Create;
  fActiveEntries := TList<TActiveKeyIndexStringEntry>.Create;
end;

destructor TActiveKeyIndexStrings.Destroy;
begin
  fActiveEntries.Free;
  fAllEntries.Free;
  inherited;
end;

procedure TActiveKeyIndexStrings.AddString(const aId: UInt32; const aActive: Boolean; const aTitle: string);
begin
  var lEntry := TActiveKeyIndexStringEntry.Create;
  lEntry.Id := aId;
  lEntry.Title := aTitle;
  fAllEntries.Add(lEntry);
  if aActive then
    fActiveEntries.Add(lEntry);
end;

function TActiveKeyIndexStrings.GetActiveEntries: TKeyIndexStringsData;
begin
  Result := GetEntries(fActiveEntries);
end;

function TActiveKeyIndexStrings.GetAllEntries: TKeyIndexStringsData;
begin
  Result := GetEntries(fAllEntries);
end;

function TActiveKeyIndexStrings.GetEntries(const aList: TList<TActiveKeyIndexStringEntry>): TKeyIndexStringsData;
begin
  Result := TKeyIndexStringsData.Create;
  Result.BeginUpdate;
  for var lEntry in aList do
    Result.AddMappedString(lEntry.Id, lEntry.Title);
  Result.EndUpdate;
end;

end.
