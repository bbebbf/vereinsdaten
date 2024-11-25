unit CrudAccessor;

interface

uses System.Classes, System.SysUtils, System.Generics.Collections, Data.DB, SqlConnection, Transaction;

type
  ECrudAccessorException = class(Exception);

  TCrudAccessorColumnInfo = class
  strict private
    fColumnIndex: Integer;
    fColumnName: string;
    fColumnType: TFieldType;
    fIsIdentityColumn: Boolean;
    function GetIsIdentityColumn: Boolean;
    function GetIsAutoInc: Boolean;
  public
    constructor Create(const aColumnIndex: Integer; const aColumnName: string;
      const aColumnType: TFieldType; const aIsIdentityColumn: Boolean);
    function ParameterName(const aForStatement: Boolean): string;
    property ColumnName: string read fColumnName;
    property ColumnType: TFieldType read fColumnType;
    property IsIdentityColumn: Boolean read GetIsIdentityColumn;
    property IsAutoInc: Boolean read GetIsAutoInc;
  end;

  TCrudAccessorBase = class abstract
  strict private
    fConnection: ISqlConnection;
    fTablename: string;
    fIdentityColumnNames: TStringList;
    fColumnInfos: TObjectDictionary<string, TCrudAccessorColumnInfo>;
    fParamsDict: TDictionary<string, ISqlParameter>;
    fPreparedStmt: ISqlPreparedCommand;
    fAutoIncPresent: Boolean;
    fValues: TDictionary<string, Variant>;
    function GetVariantValue<T>(const aValue: T): Variant;
    procedure Prepare(aTransaction: ITransaction);
    function FindColumnInfoByParameterName(const aParameterName: string): TCrudAccessorColumnInfo;
    function TryAssignValuesToParameters(const aRaiseOnFailure: Boolean): Boolean;
  strict protected
    function FindColumnInfoByColumnName(const aColumnName: string): TCrudAccessorColumnInfo;
    procedure PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string); virtual; abstract;
    procedure RaiseIfExecuteStmtIsInvalid; virtual;
    function Execute(aTransaction: ITransaction): Boolean;
  public
    constructor Create(aConnection: ISqlConnection; const aTablename: string;
      const aIdentityColumnNames: TArray<string> = []);
    destructor Destroy; override;
    procedure SetValue<T>(const aColumnName: string; const aValue: T);
    procedure SetValueToNull(const aColumnName: string);
    procedure SetValueEmptyStrAsNull(const aColumnName: string; const aValue: string);
    procedure SetValueZeroAsNull(const aColumnName: string; const aValue: Int64); overload;
    procedure SetValueZeroAsNull(const aColumnName: string; const aValue: TDateTime); overload;
    procedure SetAllValuesToNull;
    property Connection: ISqlConnection read fConnection;
    property Tablename: string read fTablename;
    property AutoIncPresent: Boolean read fAutoIncPresent;
  end;

  TCrudAccessorInsert = class(TCrudAccessorBase)
  strict private
    fLastInsertedId: Int64;
  strict protected
    procedure PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string); override;
  public
    function Insert(aTransaction: ITransaction = nil): Boolean;
    property LastInsertedId: Int64 read fLastInsertedId;
  end;

  TCrudAccessorUpdate = class(TCrudAccessorBase)
  strict protected
    procedure PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string); override;
  public
    function Update(aTransaction: ITransaction = nil): Boolean;
  end;

  TCrudAccessorDelete = class(TCrudAccessorBase)
  strict protected
    procedure PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string); override;
  public
    function Delete(aTransaction: ITransaction = nil): Boolean;
  end;

implementation

uses System.Rtti, System.TypInfo, System.Variants, System.Generics.Defaults, StringTools;

{ TCrudAccessorBase }

constructor TCrudAccessorBase.Create(aConnection: ISqlConnection; const aTablename: string;
  const aIdentityColumnNames: TArray<string>);
begin
  inherited Create;
  fColumnInfos := TObjectDictionary<string, TCrudAccessorColumnInfo>.Create([doOwnsValues], TIStringComparer.Ordinal);
  fParamsDict := TDictionary<string, ISqlParameter>.Create(TIStringComparer.Ordinal);
  fValues := TDictionary<string, Variant>.Create(TIStringComparer.Ordinal);
  fIdentityColumnNames := TStringList.Create;
  fIdentityColumnNames.CaseSensitive := False;
  fIdentityColumnNames.Duplicates := TDuplicates.dupIgnore;
  fIdentityColumnNames.Sorted := True;
  fConnection := aConnection;
  fTablename := aTablename;
  fIdentityColumnNames.AddStrings(aIdentityColumnNames);
end;

destructor TCrudAccessorBase.Destroy;
begin
  fIdentityColumnNames.Free;
  fValues.Free;
  fParamsDict.Free;
  fColumnInfos.Free;
  inherited;
end;

function TCrudAccessorBase.Execute(aTransaction: ITransaction): Boolean;
begin
  if not TryAssignValuesToParameters(False) then
  begin
    Prepare(aTransaction);
    TryAssignValuesToParameters(True);
  end;
  if not Assigned(fPreparedStmt) then
    raise ECrudAccessorException.Create('Interal Sql statement is not prepared.');

  RaiseIfExecuteStmtIsInvalid;
  Result := fPreparedStmt.Execute > 0;
end;

function TCrudAccessorBase.TryAssignValuesToParameters(const aRaiseOnFailure: Boolean): Boolean;
begin
  Result := True;
  for var lEntry: TPair<string, Variant> in fValues do
  begin
    if fParamsDict.ContainsKey(lEntry.Key) then
    begin
      fParamsDict[lEntry.Key].Value := lEntry.Value
    end
    else
    begin
      if aRaiseOnFailure then
        raise ECrudAccessorException.Create('Column "' + lEntry.Key + '" is not parameterized table ' + Tablename + '.');
      Exit(False);
    end;
  end;
end;

procedure TCrudAccessorBase.Prepare(aTransaction: ITransaction);
begin
  fPreparedStmt := nil;
  fColumnInfos.Clear;
  fParamsDict.Clear;
  fAutoIncPresent := False;

  var lMetadata := fConnection.GetSelectResult('select * from ' + fTablename + ' where 0=1');
  for var i := 0 to lMetadata.FieldCount - 1 do
  begin
    var lColumnName := lMetadata.FieldDefs[i].Name;
    var lColumnType := lMetadata.FieldDefs[i].DataType;
    var lIsIdentityColumn := False;
    if lColumnType = ftAutoInc then
    begin
      fAutoIncPresent := True;
      lIsIdentityColumn := True;
    end;
    lIsIdentityColumn := lIsIdentityColumn or fIdentityColumnNames.Contains(lColumnName);
    if fValues.ContainsKey(lColumnName) then
      fColumnInfos.Add(lColumnName,
        TCrudAccessorColumnInfo.Create(i, lColumnName, lColumnType, lIsIdentityColumn));
  end;

  var lSqlStatement := '';
  PrepareStmt(fColumnInfos.Values, lSqlStatement);
  fPreparedStmt := fConnection.CreatePreparedCommand(lSqlStatement, aTransaction);
  for var i := 0 to fPreparedStmt.ParamCount - 1 do
  begin
    var lColumnInfo := FindColumnInfoByParameterName(fPreparedStmt.Params[i].Name);
    if not Assigned(lColumnInfo) then
      raise ECrudAccessorException.Create('No column info found for parameter name "' +
        fPreparedStmt.Params[i].Name + '".');

    if fPreparedStmt.Params[i].DataType = ftUnknown then
      fPreparedStmt.Params[i].DataType := lColumnInfo.ColumnType;

    fParamsDict.Add(lColumnInfo.ColumnName, fPreparedStmt.Params[i]);
  end;
end;

function TCrudAccessorBase.FindColumnInfoByColumnName(const aColumnName: string): TCrudAccessorColumnInfo;
begin
  if fColumnInfos.TryGetValue(aColumnName, Result) then
    Exit;
  Result := nil;
end;

function TCrudAccessorBase.FindColumnInfoByParameterName(const aParameterName: string): TCrudAccessorColumnInfo;
begin
  Result := nil;
  for var lEntry in fColumnInfos.Values do
    if SameText(aParameterName, lEntry.ParameterName(False)) then
      Exit(lEntry);
end;

procedure TCrudAccessorBase.SetValue<T>(const aColumnName: string; const aValue: T);
begin
  fValues.AddOrSetValue(aColumnName, GetVariantValue(aValue));
end;

procedure TCrudAccessorBase.SetValueToNull(const aColumnName: string);
begin
  fValues.AddOrSetValue(aColumnName, System.Variants.Null);
end;

procedure TCrudAccessorBase.SetValueEmptyStrAsNull(const aColumnName, aValue: string);
begin
  if Length(aValue) = 0 then
    SetValueToNull(aColumnName)
  else
    SetValue(aColumnName, aValue);
end;

procedure TCrudAccessorBase.SetValueZeroAsNull(const aColumnName: string; const aValue: Int64);
begin
  if aValue = 0 then
    SetValueToNull(aColumnName)
  else
    SetValue(aColumnName, aValue);
end;

procedure TCrudAccessorBase.SetValueZeroAsNull(const aColumnName: string; const aValue: TDateTime);
begin
  if aValue = 0 then
    SetValueToNull(aColumnName)
  else
    SetValue(aColumnName, aValue);
end;

procedure TCrudAccessorBase.SetAllValuesToNull;
begin
  fValues.Clear;
  for var lParameter in fParamsDict.Values do
    lParameter.Value := System.Variants.Null;
end;

function TCrudAccessorBase.GetVariantValue<T>(const aValue: T): Variant;
begin
  var lVarValue := TValue.From<T>(aValue);
  case lVarValue.Kind of
    tkEnumeration:
    begin
      if lVarValue.TypeInfo = TypeInfo(Boolean) then
        Result := lVarValue.AsBoolean
      else
        Result := lVarValue.AsOrdinal;
    end
    else
    begin
      Result := lVarValue.AsVariant;
    end;
  end;
end;

procedure TCrudAccessorBase.RaiseIfExecuteStmtIsInvalid;
begin

end;

{ TCrudAccessorInsert }

function TCrudAccessorInsert.Insert(aTransaction: ITransaction): Boolean;
begin
  Result := Execute(aTransaction);
  if AutoIncPresent then
    fLastInsertedId := Connection.GetLastInsertedIdentityScoped
  else
    fLastInsertedId := -1;
end;

procedure TCrudAccessorInsert.PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string);
begin
  var lInsertFieldList := '';
  var lInsertValueList := '';
  for var lColumnInfo in aColumnInfos do
  begin
    if lColumnInfo.IsAutoInc then
      Continue;

    lInsertFieldList := TStringTools.Combine(lInsertFieldList, ',', lColumnInfo.ColumnName);
    lInsertValueList := TStringTools.Combine(lInsertValueList, ',', lColumnInfo.ParameterName(True));
  end;
  if Length(lInsertFieldList) = 0 then
    raise ECrudAccessorException.Create('No proper columns for insert found for table ' + Tablename);

  aSql := 'insert into ' + Tablename + '(' + lInsertFieldList + ') values(' + lInsertValueList + ')';
end;

{ TCrudAccessorUpdate }

function TCrudAccessorUpdate.Update(aTransaction: ITransaction): Boolean;
begin
  Result := Execute(aTransaction);
end;

procedure TCrudAccessorUpdate.PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string);
begin
  var lUpdatableFieldList := '';
  var lIdentityFieldList := '';
  for var lColumnInfo in aColumnInfos do
  begin
    if lColumnInfo.IsIdentityColumn then
    begin
      lIdentityFieldList := TStringTools.Combine(lIdentityFieldList, ' and ',
        '(' + lColumnInfo.ColumnName + '=' + lColumnInfo.ParameterName(True) + ')');
    end
    else
    begin
      lUpdatableFieldList := TStringTools.Combine(lUpdatableFieldList, ',',
        lColumnInfo.ColumnName + '=' + lColumnInfo.ParameterName(True));
    end;
  end;
  if Length(lIdentityFieldList) = 0 then
    raise ECrudAccessorException.Create('No proper identity columns found for table ' + Tablename);
  if Length(lUpdatableFieldList) = 0 then
    raise ECrudAccessorException.Create('No proper columns for update found for table ' + Tablename);

  aSql := 'update ' + Tablename + ' set ' + lUpdatableFieldList + ' where ' + lIdentityFieldList;
end;

{ TCrudAccessorDelete }

function TCrudAccessorDelete.Delete(aTransaction: ITransaction): Boolean;
begin
  Result := Execute(aTransaction);
end;

procedure TCrudAccessorDelete.PrepareStmt(const aColumnInfos: TEnumerable<TCrudAccessorColumnInfo>; out aSql: string);
begin
  var lIdentityFieldList := '';
  for var lColumnInfo in aColumnInfos do
  begin
    if not lColumnInfo.IsIdentityColumn then
      Exit;

    lIdentityFieldList := TStringTools.Combine(lIdentityFieldList, ' and ',
      '(' + lColumnInfo.ColumnName + '=' + lColumnInfo.ParameterName(True) + ')');
  end;
  if Length(lIdentityFieldList) = 0 then
    raise ECrudAccessorException.Create('No proper identity columns found for table ' + Tablename);

  aSql := 'delete from ' + Tablename + ' where ' + lIdentityFieldList;
end;

{ TCrudAccessorColumnInfo }

constructor TCrudAccessorColumnInfo.Create(const aColumnIndex: Integer; const aColumnName: string;
  const aColumnType: TFieldType; const aIsIdentityColumn: Boolean);
begin
  inherited Create;
  fColumnIndex := aColumnIndex;
  fColumnName := aColumnName;
  fColumnType := aColumnType;
  fIsIdentityColumn := aIsIdentityColumn;
end;

function TCrudAccessorColumnInfo.GetIsAutoInc: Boolean;
begin
  Result := fColumnType = TFieldType.ftAutoInc;
end;

function TCrudAccessorColumnInfo.GetIsIdentityColumn: Boolean;
begin
  Result := IsAutoInc or fIsIdentityColumn;
end;

function TCrudAccessorColumnInfo.ParameterName(const aForStatement: Boolean): string;
begin
  if aForStatement then
    Result := ':P' + IntToStr(fColumnIndex)
  else
    Result := 'P' + IntToStr(fColumnIndex);
end;

end.
