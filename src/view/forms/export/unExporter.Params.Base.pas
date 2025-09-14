unit unExporter.Params.Base;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unParamsDlg, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  TfmExporterParamsBase = class(TfmParamsDlg)
    pnTarget: TPanel;
    cbTargets: TComboBox;
    lbTargets: TLabel;
  strict protected
    procedure SetTargets(const aTargets: TArray<string>);
    function GetTargetIndex: Integer;
  end;

implementation

{$R *.dfm}

{ TfmExporterParamsBase }

function TfmExporterParamsBase.GetTargetIndex: Integer;
begin
  Result := cbTargets.ItemIndex;
end;

procedure TfmExporterParamsBase.SetTargets(const aTargets: TArray<string>);
begin
  cbTargets.Items.BeginUpdate;
  try
    cbTargets.Items.Clear;
    for var i := Low(aTargets) to High(aTargets) do
      cbTargets.Items.Add(aTargets[i]);
    if Length(aTargets) > 0 then
      cbTargets.ItemIndex := 0
    else
      cbTargets.ItemIndex := -1;
  finally
    cbTargets.Items.EndUpdate;
  end;
  cbTargets.Enabled := cbTargets.Items.Count > 1;
end;

end.
