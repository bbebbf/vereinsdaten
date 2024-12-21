unit unSimpleMasterdataForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.ToolWin, Vcl.StdCtrls;

type
  TfmSimpleMasterdataForm = class(TForm)
    pnList: TPanel;
    Splitter1: TSplitter;
    pnRecord: TPanel;
    pnFilter: TPanel;
    lvListview: TListView;
    btNewRecord: TButton;
    pnActions: TPanel;
    btPersonSave: TButton;
    btPersonReload: TButton;
  private
    { Private-Deklarationen }
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

end.
