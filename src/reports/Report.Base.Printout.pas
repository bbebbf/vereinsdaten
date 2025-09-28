unit Report.Base.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SqlConnection, Exporter.Types;

type
  TfmReportBasePrintout = class(TForm)
  strict protected
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    function ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
    procedure ExportInternal(const aDataSet: ISqlDataSet); virtual;
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

function TfmReportBasePrintout.ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
begin
  Result := default(TExporterExportResult);
  Result.Sucessful := True;
  ExportInternal(aDataSet);
end;

procedure TfmReportBasePrintout.ExportInternal(const aDataSet: ISqlDataSet);
begin

end;

function TfmReportBasePrintout.GetResultMessageRequired: Boolean;
begin
  Result := False;
end;

function TfmReportBasePrintout.GetTitle: string;
begin
  Result := 'Ausdruck';
end;

end.
