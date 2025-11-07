unit unExporter.Params.Persons;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls,
  ParamsProvider, Exporter.Persons.Types;

type
  TfmExporterParamsPersons = class(TfmExporterParamsBase, IParamsProvider<TExporterPersonsParams>)
    cbShowInactivePersons: TCheckBox;
    cbShowExternalPersons: TCheckBox;
  strict private
    function GetParams(const aParams: TExporterPersonsParams): TExporterPersonsParams;
    procedure SetParams(const aParams: TExporterPersonsParams);
    function ShouldBeExported(const aParams: TExporterPersonsParams): Boolean;
  end;

implementation

{$R *.dfm}

{ TfmExporterParamsPersons }

function TfmExporterParamsPersons.GetParams(const aParams: TExporterPersonsParams): TExporterPersonsParams;
begin
  Result := aParams;
  Result.IncludeInactive := cbShowInactivePersons.Checked;
  Result.IncludeExternal := cbShowExternalPersons.Checked;
end;

procedure TfmExporterParamsPersons.SetParams(const aParams: TExporterPersonsParams);
begin
  cbShowInactivePersons.Checked := aParams.IncludeInactive;
  cbShowExternalPersons.Checked := aParams.IncludeExternal;
end;

function TfmExporterParamsPersons.ShouldBeExported(const aParams: TExporterPersonsParams): Boolean;
begin
  Result := True;
end;

end.
