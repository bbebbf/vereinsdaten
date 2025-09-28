unit Report.Base.Csv;

interface

uses System.Generics.Collections, InterfacedBase, SqlConnection, Exporter.Types, CsvWriter;

type
  TReportCsvField = class
  public
    FieldName: string;
  end;

  TReportBaseCsv = class(TInterfacedBase, IExporterTargetConfig, IExporterRequiresFilePath)
  strict private
    fFilePath: string;
    fFieldsToExport: TObjectList<TReportCsvField>;
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    function GetFilePath: string;
    procedure SetFilePath(const aValue: string);
  strict protected
    function GetSuggestedFileName: string; virtual;
    function ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
    procedure Assign(const aExporterRequiresFilePath: IExporterRequiresFilePath);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses System.Classes, System.SysUtils, System.Variants;

{ TReportBaseCsv }

constructor TReportBaseCsv.Create;
begin
  inherited Create;
  fFieldsToExport := TObjectList<TReportCsvField>.Create;
end;

destructor TReportBaseCsv.Destroy;
begin
  fFieldsToExport.Free;
  inherited;
end;

procedure TReportBaseCsv.Assign(const aExporterRequiresFilePath: IExporterRequiresFilePath);
begin
  fFilePath := aExporterRequiresFilePath.FilePath;
end;

function TReportBaseCsv.ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
begin
  Result := default(TExporterExportResult);
  var lFileStream := TFileStream.Create(fFilePath, fmCreate or fmOpenWrite);
  try
    var lCsvWriter := TCsvWriter.GetInstance(lFileStream);
    for var i in aDataSet.DataSet.FieldDefs do
    begin
      lCsvWriter.AddValue(i.DisplayName);
    end;
    lCsvWriter.NewLine;
    while not aDataSet.DataSet.Eof do
    begin
      for var i in aDataSet.DataSet.Fields do
      begin
        var lValue := i.Value;
        var lValueStr := VarToStr(lValue);
        lCsvWriter.AddValue(lValueStr);
      end;
      lCsvWriter.NewLine;
      aDataSet.DataSet.Next;
    end;
    Result.Sucessful := True;
    Result.FilePath := fFilePath;
  finally
    lFileStream.Free;
  end;
end;

function TReportBaseCsv.GetFilePath: string;
begin
  Result := fFilePath;
end;

function TReportBaseCsv.GetResultMessageRequired: Boolean;
begin
  Result := True;
end;

procedure TReportBaseCsv.SetFilePath(const aValue: string);
begin
  fFilePath := aValue;
end;

function TReportBaseCsv.GetSuggestedFileName: string;
begin
  Result := '';
end;

function TReportBaseCsv.GetTitle: string;
begin
  Result := 'CSV-Datei';
end;

end.
