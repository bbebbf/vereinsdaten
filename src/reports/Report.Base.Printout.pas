unit Report.Base.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TfmReportBasePrintout = class(TForm)
  strict protected
    function GetTitle: string;
  public
    constructor Create; reintroduce;
  end;

implementation

{$R *.dfm}

{ TfmReportBase }

constructor TfmReportBasePrintout.Create;
begin
  inherited Create(nil);
end;

function TfmReportBasePrintout.GetTitle: string;
begin
  Result := 'Ausdruck';
end;

end.
