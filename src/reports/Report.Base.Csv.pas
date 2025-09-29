unit Report.Base.Csv;

interface

uses System.Generics.Collections, Data.DB, InterfacedBase, SqlConnection, Exporter.Types, CsvWriter;

type
  TReportCsvValueToStrEvent = reference to procedure(const aField: TField; var aValue: string);

  TReportCsvField = class
  strict private
    fFieldName: string;
    fValueToStrEvent: TReportCsvValueToStrEvent;
  public
    constructor Create(const aFieldName: string); overload;
    constructor Create(const aFieldName: string; const aValueToStrEvent: TReportCsvValueToStrEvent); overload;
    property FieldName: string read fFieldName;
    property ValueToStrEvent: TReportCsvValueToStrEvent read fValueToStrEvent;
  end;

  TReportBaseCsv = class(TInterfacedBase, IExporterTargetConfig, IExporterRequiresFilePath)
  strict private
    fFieldsToExport: TObjectList<TReportCsvField>;
    fFilePath: string;
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    function GetFilePath: string;
    procedure SetFilePath(const aValue: string);
    function GetFieldsToExportInternal(const aFields: TFields): TList<TPair<TField, TReportCsvValueToStrEvent>>;
  strict protected
    function GetSuggestedFileName: string; virtual;
    procedure FillFieldsToExport(const aFields: TObjectList<TReportCsvField>); virtual;
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
  var lFieldsToExport := GetFieldsToExportInternal(aDataSet.DataSet.Fields);
  try
    var lFileStream := TFileStream.Create(fFilePath, fmCreate or fmOpenWrite);
    try
      var lCsvWriter := TCsvWriter.GetInstance(lFileStream);
      for var i in lFieldsToExport do
        lCsvWriter.AddValue(i.Key.FieldName);
      lCsvWriter.NewLine;
      while not aDataSet.DataSet.Eof do
      begin
        for var i in lFieldsToExport do
        begin
          var lValue := i.Key.Value;
          var lValueStr := VarToStr(lValue);
          if Assigned(i.Value) then
            i.Value(i.Key, lValueStr);
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
  finally
    lFieldsToExport.Free;
  end;
end;

function TReportBaseCsv.GetFieldsToExportInternal(const aFields: TFields): TList<TPair<TField, TReportCsvValueToStrEvent>>;
begin
  Result := TList<TPair<TField, TReportCsvValueToStrEvent>>.Create;
  fFieldsToExport.Clear;
  FillFieldsToExport(fFieldsToExport);
  if fFieldsToExport.Count = 0 then
  begin
    for var i in aFields do
      Result.Add(TPair<TField, TReportCsvValueToStrEvent>.Create(i, nil));
    Exit;
  end;

  for var i in fFieldsToExport do
  begin
    var lField := aFields.FieldByName(i.FieldName);
    if Assigned(lField) then
      Result.Add(TPair<TField, TReportCsvValueToStrEvent>.Create(lField, i.ValueToStrEvent));
  end;
end;

procedure TReportBaseCsv.FillFieldsToExport(const aFields: TObjectList<TReportCsvField>);
begin
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

{ TReportCsvField }

constructor TReportCsvField.Create(const aFieldName: string);
begin
  Create(aFieldName, nil);
end;

constructor TReportCsvField.Create(const aFieldName: string; const aValueToStrEvent: TReportCsvValueToStrEvent);
begin
  inherited Create;
  fFieldName := aFieldName;
  fValueToStrEvent := aValueToStrEvent;
end;

end.
