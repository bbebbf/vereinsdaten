unit unSelectConnection;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfmSelectConnection = class(TForm)
    btStartApp: TButton;
    btCancelAppStart: TButton;
    cbConnections: TComboBox;
  public
    function Execute: Boolean;
  end;

implementation

{$R *.dfm}

uses ConfigReader;

{ TfmSelectConnection }

function TfmSelectConnection.Execute: Boolean;
begin
  Result := False;
  cbConnections.Items.Assign(TConfigReader.Instance.ConnectionNames);
  if cbConnections.Items.Count = 0 then
    Exit;

  cbConnections.ItemIndex := 0;
  if ShowModal = mrOk then
  begin
    TConfigReader.Instance.SelectConnection(cbConnections.ItemIndex);
    Result := True;
  end;
end;

end.
