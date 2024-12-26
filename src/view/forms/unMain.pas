unit unMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.Menus, System.Actions, Vcl.ActnList,
  unPerson, SqlConnection, ProgressIndicator, PersonBusinessIntf, PersonBusiness;

type
  TfmMain = class(TForm)
    MainMenu: TMainMenu;
    Stammdaten1: TMenuItem;
    StatusBar: TStatusBar;
    ActionList: TActionList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
  strict private
    fActivated: Boolean;
    fConnection: ISqlConnection;
    fProgressIndicator: IProgressIndicator;
    fPersonBusinessIntf: IPersonBusinessIntf;
    ffraPerson: TfraPerson;
  public
    property Connection: ISqlConnection read fConnection write fConnection;
    property ProgressIndicator: IProgressIndicator read fProgressIndicator write fProgressIndicator;
  end;

var
  fmMain: TfmMain;

implementation

uses Vdm.Globals, ConfigReader;

{$R *.dfm}

procedure TfmMain.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;

  fActivated := True;
  fPersonBusinessIntf := TPersonBusiness.Create(fConnection, ffraPerson, fProgressIndicator);
  fPersonBusinessIntf.Initialize;
  fPersonBusinessIntf.LoadList;
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Caption := TVdmGlobals.GetVdmApplicationTitle;

  var lConnectionInfo := 'Server: ' + TConfigReader.Instance.Connection.Host +
    ':' + IntToStr(TConfigReader.Instance.Connection.Port);
  if Length(TConfigReader.Instance.Connection.SshRemoteHost) > 0 then
    lConnectionInfo := 'Remote Host: ' + TConfigReader.Instance.Connection.SshRemoteHost + ' / ' + lConnectionInfo;
  StatusBar.SimpleText := lConnectionInfo;

  ffraPerson := TfraPerson.Create(Self);
  ffraPerson.Parent := Self;
  ffraPerson.Align := TAlign.alClient;
  ffraPerson.Show;
end;

procedure TfmMain.FormDestroy(Sender: TObject);
begin
  fPersonBusinessIntf := nil;
  fProgressIndicator := nil;
  fConnection := nil;
end;

end.
