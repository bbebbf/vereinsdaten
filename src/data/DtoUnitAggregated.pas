unit DtoUnitAggregated;

interface

uses System.Generics.Collections, DtoPersonNameId, DtoUnit, Vdm.Versioning.Types, Nullable;

type
  TDtoUnitAggregated = class
  strict private
    fUnit: TDtoUnit;
    fVersionInfo: TVersionInfoEntry;
  public
    constructor Create(const aUnit: TDtoUnit);
    destructor Destroy; override;
    function ToString: string; override;
    procedure UpdateByDtoUnit(const aUnit: TDtoUnit);
    property VersionInfo: TVersionInfoEntry read fVersionInfo;
    property &Unit: TDtoUnit read fUnit;
    property Id: UInt32 read fUnit.Id write fUnit.Id;
    property Name: string read fUnit.Name write fUnit.Name;
    property Active: Boolean read fUnit.Active write fUnit.Active;
    property ActiveSince: INullable<TDate> read fUnit.ActiveSince write fUnit.ActiveSince;
    property ActiveUntil: INullable<TDate> read fUnit.ActiveUntil write fUnit.ActiveUntil;
    property Kind: TUnitKind read fUnit.Kind write fUnit.Kind;
    property DataConfirmedOn: INullable<TDate> read fUnit.DataConfirmedOn write fUnit.DataConfirmedOn;
  end;

implementation

{ TDtoUnitAggregated }

constructor TDtoUnitAggregated.Create(const aUnit: TDtoUnit);
begin
  inherited Create;
  fUnit := aUnit;
  fVersionInfo := TVersionInfoEntry.Create;
end;

destructor TDtoUnitAggregated.Destroy;
begin
  fVersionInfo.Free;
  inherited;
end;

function TDtoUnitAggregated.ToString: string;
begin
  Result := fUnit.ToString;
end;

procedure TDtoUnitAggregated.UpdateByDtoUnit(const aUnit: TDtoUnit);
begin
  fUnit := aUnit;
end;

end.
