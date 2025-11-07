unit Exporter.Members.Types;

interface

uses Exporter.Persons.Types, Exporter.Units.Types;

type
  TExporterMembersParams = class
  strict private
    fPersons: TExporterPersonsParams;
    fUnits: TExporterUnitsParams;
    fIncludeAllInactiveMembers: Boolean;
    fInactiveMembersButActiveUntil: TDate;
  public
    constructor Create;
    destructor Destroy; override;
    property Persons: TExporterPersonsParams read fPersons;
    property Units: TExporterUnitsParams read fUnits;
    property IncludeAllInactiveMembers: Boolean read fIncludeAllInactiveMembers write fIncludeAllInactiveMembers;
    property InactiveMembersButActiveUntil: TDate read fInactiveMembersButActiveUntil write fInactiveMembersButActiveUntil;
  end;

implementation

{ TExporterMembersParams }

constructor TExporterMembersParams.Create;
begin
  inherited Create;
  fPersons := TExporterPersonsParams.Create;
  fUnits := TExporterUnitsParams.Create;
end;

destructor TExporterMembersParams.Destroy;
begin
  fUnits.Free;
  fPersons.Free;
  inherited;
end;

end.
