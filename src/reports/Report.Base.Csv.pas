unit Report.Base.Csv;

interface

uses System.SysUtils, System.Generics.Collections, Data.DB, InterfacedBase, SqlConnection, Exporter.Types, CsvWriter;

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
    type
      TInternalFieldInfo = class
      public
        Field: TField;
        ValueToStrEvent: TReportCsvValueToStrEvent;
      end;
    var
    fFormatSettings: TFormatSettings;
    fExportTimeSeconds: Boolean;
    fTimeFormatStr: string;
    fFieldsToExport: TObjectList<TReportCsvField>;
    fFilePath: string;
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    function GetFilePath: string;
    procedure SetFilePath(const aValue: string);
    function GetFieldsToExportInternal(const aFields: TFields): TObjectList<TInternalFieldInfo>;
    function GetStrFromCsvField(const aInternalField: TInternalFieldInfo): string;
    procedure SetExportTimeSeconds(const aValue: Boolean);
  strict protected
    function GetSuggestedFileName: string; virtual;
    procedure FillFieldsToExport(const aFields: TObjectList<TReportCsvField>); virtual;
    function ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
    procedure Assign(const aExporterRequiresFilePath: IExporterRequiresFilePath);
  public
    constructor Create;
    destructor Destroy; override;
    property ExportTimeSeconds: Boolean read fExportTimeSeconds write SetExportTimeSeconds;
  end;

implementation

uses System.Classes, System.Variants;

{ TReportBaseCsv }

constructor TReportBaseCsv.Create;
begin
  inherited Create;
  fFieldsToExport := TObjectList<TReportCsvField>.Create;
  fFormatSettings := TFormatSettings.Create;
  fFormatSettings.DecimalSeparator := '.';
  fFormatSettings.ThousandSeparator := #0;
  SetExportTimeSeconds(False);
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
        lCsvWriter.AddValue(i.Field.FieldName);
      lCsvWriter.NewLine;
      while not aDataSet.DataSet.Eof do
      begin
        for var i in lFieldsToExport do
          lCsvWriter.AddValue(GetStrFromCsvField(i));
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

function TReportBaseCsv.GetStrFromCsvField(const aInternalField: TInternalFieldInfo): string;
begin
  Result := '';
  if not aInternalField.Field.IsNull then
  begin
    case aInternalField.Field.DataType of
      TFieldType.ftSingle,
      TFieldType.ftFloat,
      TFieldType.ftExtended,
      TFieldType.ftBCD,
      TFieldType.ftCurrency:
      begin
        Result := FloatToStr(aInternalField.Field.AsExtended, fFormatSettings);
      end;
      TFieldType.ftBoolean:
      begin
        if aInternalField.Field.AsBoolean then
          Result := '1'
        else
          Result := '0';
      end;
      TFieldType.ftDate:
      begin
        Result := FormatDateTime('yyyy-mm-dd', aInternalField.Field.AsDateTime, fFormatSettings);
      end;
      TFieldType.ftTime:
      begin
        Result := FormatDateTime(fTimeFormatStr, aInternalField.Field.AsDateTime, fFormatSettings);
      end;
      TFieldType.ftDateTime,
      TFieldType.ftTimeStamp:
      begin
        Result := FormatDateTime('yyyy-mm-dd ' + fTimeFormatStr, aInternalField.Field.AsDateTime, fFormatSettings);
      end
      else
      begin
        var lValue := aInternalField.Field.Value;
        Result := VarToStr(lValue);
      end;
    end;
  end;
  if Assigned(aInternalField.ValueToStrEvent) then
    aInternalField.ValueToStrEvent(aInternalField.Field, Result);
end;

function TReportBaseCsv.GetFieldsToExportInternal(const aFields: TFields): TObjectList<TInternalFieldInfo>;
begin
  Result := TObjectList<TInternalFieldInfo>.Create;
  fFieldsToExport.Clear;
  FillFieldsToExport(fFieldsToExport);
  if fFieldsToExport.Count = 0 then
  begin
    for var i in aFields do
    begin
      var lEntry := TInternalFieldInfo.Create;
      lEntry.Field := i;
      Result.Add(lEntry);
    end;
  end;

  for var i in fFieldsToExport do
  begin
    var lField := aFields.FindField(i.FieldName);
    if not Assigned(lField) then
      raise Exception.Create('Field name "' + i.FieldName + '" not found.');

    var lEntry := TInternalFieldInfo.Create;
    lEntry.Field := lField;
    lEntry.ValueToStrEvent := i.ValueToStrEvent;
    Result.Add(lEntry);
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

procedure TReportBaseCsv.SetExportTimeSeconds(const aValue: Boolean);
begin
  fExportTimeSeconds := aValue;
  if fExportTimeSeconds then
  begin
    fTimeFormatStr := 'hh:nn:ss';
  end
  else
  begin
    fTimeFormatStr := 'hh:nn';
  end;
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
