unit unExporter.Params.ZeroParams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unExporter.Params.Base, Vcl.StdCtrls, Vcl.ExtCtrls,
  ParamsProvider;

type
  TfmExporterParamsZeroParams = class(TfmExporterParamsBase, IParamsProvider<TObject>)
  private
    function GetParams(const aParams: TObject): TObject;
    procedure SetParams(const aParams: TObject);
    function ShouldBeExported(const aParams: TObject): Boolean;
  end;

implementation

{$R *.dfm}

{ TfmExporterParamsZeroParams }

function TfmExporterParamsZeroParams.GetParams(const aParams: TObject): TObject;
begin
  Result := aParams;
end;

procedure TfmExporterParamsZeroParams.SetParams(const aParams: TObject);
begin

end;

function TfmExporterParamsZeroParams.ShouldBeExported(const aParams: TObject): Boolean;
begin
  Result := True;
end;

end.
