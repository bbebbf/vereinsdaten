unit Report.Base;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfmReportBase = class(TForm)
  strict protected
    function GetTitle: string;
  public
  end;

implementation

{$R *.dfm}

{ TfmReportBase }

function TfmReportBase.GetTitle: string;
begin
  Result := 'Ausdruck';
end;

end.
