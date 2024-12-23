unit DtoUnitAggregated;

interface

uses DtoUnit;

type
  TDtoUnitAggregated = class
  strict private
    fUnit: TDtoUnit;
  public
    constructor Create(const aUnit: TDtoUnit);
    function ToString: string; override;
    procedure UpdateByDtoUnit(const aUnit: TDtoUnit);
    property &Unit: TDtoUnit read fUnit;
    property Id: UInt32 read fUnit.Id write fUnit.Id;
    property Name: string read fUnit.Name write fUnit.Name;
    property Active: Boolean read fUnit.Active write fUnit.Active;
    property ActiveSince: TDate read fUnit.ActiveSince write fUnit.ActiveSince;
    property ActiveUntil: TDate read fUnit.ActiveUntil write fUnit.ActiveUntil;
  end;

implementation

{ TDtoUnitAggregated }

constructor TDtoUnitAggregated.Create(const aUnit: TDtoUnit);
begin
  inherited Create;
  fUnit := aUnit;
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
