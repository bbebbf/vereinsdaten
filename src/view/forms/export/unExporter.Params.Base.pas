unit unExporter.Params.Base;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, unParamsDlg, Vcl.StdCtrls, Vcl.ExtCtrls, Exporter.Types, Vcl.ExtDlgs;

type
  TfmExporterParamsBase = class(TfmParamsDlg, IExporterTargetProvider, IExporterResultMessageNotifier)
    pnTarget: TPanel;
    cbTargets: TComboBox;
    lbTargets: TLabel;
    edFilePath: TEdit;
    lbFilePath: TLabel;
    btOpenFileDlg: TButton;
    dlgSave: TSaveDialog;
    procedure cbTargetsChange(Sender: TObject);
    procedure btOpenFileDlgClick(Sender: TObject);
  strict private
    fTargets: TArray<IExporterTargetConfig>;
    fRequiresFilePath: IExporterRequiresFilePath;
  strict protected
    procedure SetTargets(const aTargets: TArray<IExporterTargetConfig>);
    function GetTargetIndex: Integer;
    function ParamsValid: Boolean; override;
    procedure ResultMessage(const aExporterExportResult: TExporterExportResult);
  public
    constructor Create(AOwner: TComponent; const aDialogCaption: string = '');
  end;

implementation

{$R *.dfm}

uses MessageDialogs, WindowsProcess;

{ TfmExporterParamsBase }

constructor TfmExporterParamsBase.Create(AOwner: TComponent; const aDialogCaption: string);
begin
  inherited Create(AOwner);
  if Length(aDialogCaption) > 0 then
    Caption := aDialogCaption;
end;

procedure TfmExporterParamsBase.btOpenFileDlgClick(Sender: TObject);
begin
  if not Assigned(fRequiresFilePath) then
    Exit;

  dlgSave.FileName := fRequiresFilePath.SuggestedFileName;
  if dlgSave.Execute(Handle) then
  begin
    edFilePath.Text := dlgSave.FileName;
    fRequiresFilePath.FilePath := dlgSave.FileName;
  end;
end;

procedure TfmExporterParamsBase.cbTargetsChange(Sender: TObject);
begin
  inherited;
  if (cbTargets.ItemIndex >= 0) and Supports(fTargets[cbTargets.ItemIndex], IExporterRequiresFilePath, fRequiresFilePath) then
  begin
    lbFilePath.Enabled := True;
    edFilePath.Text := fRequiresFilePath.FilePath;
    edFilePath.Enabled := True;
    btOpenFileDlg.Enabled := True;
  end
  else
  begin
    lbFilePath.Enabled := False;
    edFilePath.Text := '';
    edFilePath.Enabled := False;
    btOpenFileDlg.Enabled := False;
  end;
end;

function TfmExporterParamsBase.GetTargetIndex: Integer;
begin
  Result := cbTargets.ItemIndex;
end;

function TfmExporterParamsBase.ParamsValid: Boolean;
begin
  Result := inherited ParamsValid;
  if not Result then
    Exit;

  if edFilePath.Enabled then
  begin
    if Length(edFilePath.Text) = 0 then
    begin
      TMessageDialogs.Ok('Es muss eine Ausgabedatei angegeben werden.', TMsgDlgType.mtError);
      btOpenFileDlg.Click;
      Exit(False);
    end;
  end;
end;

procedure TfmExporterParamsBase.SetTargets(const aTargets: TArray<IExporterTargetConfig>);
begin
  fTargets := aTargets;
  cbTargets.Items.BeginUpdate;
  try
    cbTargets.Items.Clear;
    for var i := Low(fTargets) to High(fTargets) do
      cbTargets.Items.Add(fTargets[i].Title);
    if Length(aTargets) > 0 then
      cbTargets.ItemIndex := 0
    else
      cbTargets.ItemIndex := -1;
  finally
    cbTargets.Items.EndUpdate;
  end;
  cbTargets.Enabled := cbTargets.Items.Count > 1;
  cbTargetsChange(cbTargets);
end;

procedure TfmExporterParamsBase.ResultMessage(const aExporterExportResult: TExporterExportResult);
begin
  if aExporterExportResult.Sucessful then
  begin
    TMessageDialogs.Ok(aExporterExportResult.FilePath + ' erfolgreich exportiert.', TMsgDlgType.mtInformation);
    TNewWindowsProcess.Start('explorer.exe /e,/select,"' + aExporterExportResult.FilePath + '"');
  end
  else
  begin
    TMessageDialogs.Ok(aExporterExportResult.FilePath + ' fehlerhaft exportiert.', TMsgDlgType.mtError);
  end;
end;

end.
