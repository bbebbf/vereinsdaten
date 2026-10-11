unit unExporter.Params.ClubMembers;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls,
  ParamsProvider, Exporter.ClubMembers.Types;
type
  TfmExporterParamsClubMembers = class(TfmExporterParamsBase, IParamsProvider<TExporterClubMembersParams>)
    cbIncludeInactive: TCheckBox;
    cbSortedByName: TCheckBox;
  strict private
    function GetParams(const aParams: TExporterClubMembersParams): TExporterClubMembersParams;
    procedure SetParams(const aParams: TExporterClubMembersParams);
    function ShouldBeExported(const aParams: TExporterClubMembersParams): Boolean;
  end;

implementation

{$R *.dfm}

{ TfmExporterParamsClubMembers }

function TfmExporterParamsClubMembers.GetParams(const aParams: TExporterClubMembersParams): TExporterClubMembersParams;
begin
  Result := aParams;
  Result.IncludeInactive := cbIncludeInactive.Checked;
  Result.SortedByName := cbSortedByName.Checked;
end;

procedure TfmExporterParamsClubMembers.SetParams(const aParams: TExporterClubMembersParams);
begin
  cbIncludeInactive.Checked := aParams.IncludeInactive;
  cbSortedByName.Checked := aParams.SortedByName;
end;

function TfmExporterParamsClubMembers.ShouldBeExported(const aParams: TExporterClubMembersParams): Boolean;
begin
  Result := True;
end;

end.
