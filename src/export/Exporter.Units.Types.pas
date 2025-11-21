unit Exporter.Units.Types;

interface

uses System.Generics.Collections, DtoUnit, Exporter.Params.Tools;

type
  TExporterUnitsParams = class
  strict private
    fState: TActiveRangeParams;
    fCheckedUnitIds: TList<UInt32>;
    fKinds: TUnitKinds;
  public
    constructor Create;
    destructor Destroy; override;
    procedure SetDefaultKindOnly;
    procedure IncludeOneTimeKind;
    procedure IncludeExternalKind;
    property Kinds: TUnitKinds read fKinds;
    property State: TActiveRangeParams read fState;
    property CheckedUnitIds: TList<UInt32> read fCheckedUnitIds;
  end;

  TExporterUnitDetailsParams = class
  strict private
    fSelectedUnitId: UInt32;
  public
    property SelectedUnitId: UInt32 read fSelectedUnitId write fSelectedUnitId;
  end;

implementation

{ TExporterUnitsParams }

constructor TExporterUnitsParams.Create;
begin
  inherited Create;
  fState := TActiveRangeParams.Create('unit_active', 'unit_active_since', 'unit_active_until');
  fCheckedUnitIds := TList<UInt32>.Create;
  SetDefaultKindOnly;
end;

procedure TExporterUnitsParams.SetDefaultKindOnly;
begin
  fKinds := [TUnitKind.DefaultKind];
end;

destructor TExporterUnitsParams.Destroy;
begin
  fCheckedUnitIds.Free;
  fState.Free;
  inherited;
end;

procedure TExporterUnitsParams.IncludeExternalKind;
begin
  Include(fKinds, TUnitKind.ExternalKind);
end;

procedure TExporterUnitsParams.IncludeOneTimeKind;
begin
  Include(fKinds, TUnitKind.OneTimeKind);
end;

end.
