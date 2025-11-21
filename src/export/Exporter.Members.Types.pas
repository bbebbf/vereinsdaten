unit Exporter.Members.Types;

interface

uses Exporter.Persons.Types, Exporter.Units.Types, Exporter.Params.Tools;

type
  TExporterMembersParams = class
  strict private
    fPersons: TExporterPersonsParams;
    fUnits: TExporterUnitsParams;
    fMembersState: TActiveRangeParams;
  public
    constructor Create;
    destructor Destroy; override;
    property MembersState: TActiveRangeParams read fMembersState;
    property Persons: TExporterPersonsParams read fPersons;
    property Units: TExporterUnitsParams read fUnits;
  end;

implementation

{ TExporterMembersParams }

constructor TExporterMembersParams.Create;
begin
  inherited Create;
  fMembersState := TActiveRangeParams.Create('mb_active', 'mb_active_since', 'mb_active_until');
  fPersons := TExporterPersonsParams.Create;
  fUnits := TExporterUnitsParams.Create;
end;

destructor TExporterMembersParams.Destroy;
begin
  fUnits.Free;
  fPersons.Free;
  fMembersState.Free;
  inherited;
end;

end.
