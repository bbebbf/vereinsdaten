unit Exporter.Params.Tools;

interface

uses Data.DB, SqlConnection, SqlConditionBuilder, Nullable;

type
  TActiveRecordInfo = record
  strict private
    fInitialized: Boolean;
    fActive: Boolean;
    fInactiveInfoStr: string;
    procedure SetActive(const aValue: Boolean);
    procedure SetInactiveInfoStr(const aValue: string);
  public
    procedure Reset;
    property Initialized: Boolean read fInitialized;
    property Active: Boolean read fActive write SetActive;
    property InactiveInfoStr: string read fInactiveInfoStr write SetInactiveInfoStr;
  end;

  TActiveRangeParamsKind = (Unknown, AllEntries, ActiveEntries, InactiveEntriesOnly);

  IActiveRangeParamsResult = interface
    ['{377BD875-A7CF-4528-BDAD-2C242C01E7CD}']
    function GetSqlCondition: ISqlConditionNode;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  end;

  TActiveRangeParams = class
  strict private
    fActiveColumnName: string;
    fActiveFromColumnName: string;
    fActiveToColumnName: string;
    fEntityTitle: string;
    fKind: TActiveRangeParamsKind;
    fActiveFrom: INullable<TDate>;
    fActiveTo: INullable<TDate>;
    procedure ActiveFromChanged(Sender: TObject);
    procedure ActiveToChanged(Sender: TObject);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aEntityTitle: string);
    function Get(const aTableAlias: string = ''; const aParamsPrefix: string = ''): IActiveRangeParamsResult;
    procedure ClearActiveRange;
    function GetReadableCondition: string;
    procedure GetActiveRecordInfo(const aDataSet: TDataSet;
      var aActiveRecordInfo: TActiveRecordInfo; const aTitle: string = '');
    property EntityTitle: string read fEntityTitle;
    property Kind: TActiveRangeParamsKind read fKind write fKind;
    property ActiveFrom: INullable<TDate> read fActiveFrom;
    property ActiveTo: INullable<TDate> read fActiveTo;
  end;

implementation

uses System.SysUtils, System.DateUtils, StringTools, InterfacedBase, RangeTools;

type
  TActiveRangeParamsResult = class(TInterfacedBase, IActiveRangeParamsResult)
  strict private
    fActiveColumnName: string;
    fActiveFromColumnName: string;
    fActiveToColumnName: string;
    fTableAlias: string;
    fParamsPrefix: string;
    fKind: TActiveRangeParamsKind;
    fActiveFrom: INullable<TDate>;
    fActiveTo: INullable<TDate>;
    fFromParamName: string;
    fToParamName: string;
    function GetSqlCondition: ISqlConditionNode;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName,
      aTableAlias, aParamsPrefix: string;
      const aKind: TActiveRangeParamsKind;
      const aActiveFrom, aActiveTo: INullable<TDate>);
  end;

{ TActiveRangeParams }

constructor TActiveRangeParams.Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aEntityTitle: string);
begin
  inherited Create;
  fActiveFrom := TNullable<TDate>.New;
  fActiveFrom.OnValueChanged := ActiveFromChanged;
  fActiveTo := TNullable<TDate>.New;
  fActiveTo.OnValueChanged := ActiveToChanged;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fEntityTitle := aEntityTitle;
  fKind := TActiveRangeParamsKind.ActiveEntries;
end;

procedure TActiveRangeParams.ClearActiveRange;
begin
  fActiveFrom.Reset;
  fActiveTo.Reset;
end;

function TActiveRangeParams.Get(const aTableAlias, aParamsPrefix: string): IActiveRangeParamsResult;
begin
  Result := TActiveRangeParamsResult.Create(fActiveColumnName,
    fActiveFromColumnName, fActiveToColumnName, aTableAlias, aParamsPrefix,
    fKind, fActiveFrom, fActiveTo);
end;

procedure TActiveRangeParams.GetActiveRecordInfo(const aDataSet: TDataSet;
  var aActiveRecordInfo: TActiveRecordInfo; const aTitle: string = '');
begin
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit;

  if aActiveRecordInfo.Initialized and not aActiveRecordInfo.Active then
    Exit;

  aActiveRecordInfo.Active := aDataSet.FieldByName(fActiveColumnName).AsBoolean;
  if aActiveRecordInfo.Active then
    Exit;

  var lNullableFrom := TNullable<TDate>.New;
  var lNullableTo := TNullable<TDate>.New;
  var lFieldActiveFrom := aDataSet.FieldByName(fActiveFromColumnName);
  var lFieldActiveTo := aDataSet.FieldByName(fActiveToColumnName);
  if not lFieldActiveFrom.IsNull then
    lNullableFrom.Value := lFieldActiveFrom.AsDateTime;
  if not lFieldActiveTo.IsNull then
    lNullableTo.Value := lFieldActiveTo.AsDateTime;

  var lDateRange := TRangeTools.GetDateRangeString(lNullableFrom, lNullableTo);
  if Length(lDateRange) > 0 then
    aActiveRecordInfo.InactiveInfoStr := TStringTools.Combine(
      TStringTools.Combine(aTitle, ' ', 'aktiv'), ' ', lDateRange)
  else if Length(aTitle) > 0 then
    aActiveRecordInfo.InactiveInfoStr := TStringTools.Combine(aTitle, ' ', 'inaktiv');
end;

function TActiveRangeParams.GetReadableCondition: string;
begin
  Result := '';
  if fKind = TActiveRangeParamsKind.Unknown then
    Exit;
  if fKind = TActiveRangeParamsKind.AllEntries then
    Exit('Aktive und inkative ' + fEntityTitle);
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit('Nur inaktive ' + fEntityTitle);
  if fKind = TActiveRangeParamsKind.ActiveEntries then
  begin
    var lRangeText := TRangeTools.GetDateRangeString(fActiveFrom, fActiveTo);
    if Length(lRangeText) > 0 then
    begin
      Result := 'Aktive und inaktive ' + fEntityTitle + ' (aktiv ' + lRangeText + ')';
    end;
  end;
end;

procedure TActiveRangeParams.ActiveFromChanged(Sender: TObject);
begin
  if fActiveFrom.HasValue and fActiveTo.HasValue and (CompareDate(fActiveFrom.Value, fActiveTo.Value) > 0) then
    fActiveTo.Value := fActiveFrom.Value;
end;

procedure TActiveRangeParams.ActiveToChanged(Sender: TObject);
begin
  if fActiveFrom.HasValue and fActiveTo.HasValue and (CompareDate(fActiveFrom.Value, fActiveTo.Value) > 0) then
    fActiveFrom.Value := fActiveTo.Value;
end;

{ TActiveRangeParamsResult }

constructor TActiveRangeParamsResult.Create(
  const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aTableAlias, aParamsPrefix: string;
  const aKind: TActiveRangeParamsKind;
  const aActiveFrom, aActiveTo: INullable<TDate>);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fTableAlias := aTableAlias;
  fParamsPrefix := aParamsPrefix;
  fKind := aKind;
  fActiveFrom := aActiveFrom;
  fActiveTo := aActiveTo;
end;

function TActiveRangeParamsResult.GetSqlCondition: ISqlConditionNode;
begin
  fFromParamName := '';
  fToParamName := '';
  var lSqlCondition := TSqlConditionBuilder.CreateOr;
  if fKind in [TActiveRangeParamsKind.Unknown, TActiveRangeParamsKind.AllEntries] then
    Exit(lSqlCondition);

  var lActiveColumn := TStringTools.Combine(fTableAlias, '.', fActiveColumnName);

  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
  begin
    lSqlCondition.AddEquals
      .Left(lActiveColumn)
      .Right('0');
    Exit(lSqlCondition);
  end;

  lSqlCondition.AddEquals
    .Left(lActiveColumn)
    .Right('1');

  if not fActiveFrom.HasValue and not fActiveTo.HasValue then
    Exit(lSqlCondition);

  var lParamsPrefix := fParamsPrefix;
  if Length(lParamsPrefix) = 0 then
    lParamsPrefix := fTableAlias + '_p';

  var lFromColumn := TStringTools.Combine(fTableAlias, '.', fActiveFromColumnName);
  var lToColumn := TStringTools.Combine(fTableAlias, '.', fActiveToColumnName);

  var lRangeCondition := TSqlConditionBuilder.CreateOr;
  if fActiveFrom.HasValue and fActiveTo.HasValue then
  begin
    fFromParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveFromColumnName);
    fToParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveToColumnName);

    lRangeCondition.AddAnd
      .AddIsNotNull(lFromColumn)
      .AddIsNotNull(lToColumn)
      .AddNot.AddOr
        .AddLessThan.Left(':' + fToParamName).Right(lFromColumn)
        .ParentOperator
        .AddLessThan.Left(lToColumn).Right(':' + fFromParamName);

    lRangeCondition.AddAnd
      .AddIsNotNull(lFromColumn)
      .AddIsNull(lToColumn)
      .AddLessOrEqualThan.Left(':' + fFromParamName).Right(lFromColumn)
      .ParentOperator
      .AddLessOrEqualThan.Left(lFromColumn).Right(':' + fToParamName);

    lRangeCondition.AddAnd
      .AddIsNull(lFromColumn)
      .AddIsNotNull(lToColumn)
      .AddLessOrEqualThan.Left(':' + fFromParamName).Right(lToColumn)
      .ParentOperator
      .AddLessOrEqualThan.Left(lToColumn).Right(':' + fToParamName);
  end
  else if fActiveFrom.HasValue then
  begin
    fFromParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveFromColumnName);

    lRangeCondition.AddAnd
      .AddIsNotNull(lToColumn)
      .AddLessOrEqualThan.Left(':' + fFromParamName).Right(lToColumn);
  end
  else if fActiveTo.HasValue then
  begin
    fToParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveToColumnName);

    lRangeCondition.AddAnd
      .AddIsNotNull(lFromColumn)
      .AddGreaterOrEqualThan.Left(':' + fToParamName).Right(lFromColumn)
  end;

  var lSqlConditionInactive := TSqlConditionBuilder.CreateAnd;
  lSqlConditionInactive.AddEquals
    .Left(lActiveColumn)
    .Right('0');
  lSqlConditionInactive.Add(lRangeCondition);

  Result := lSqlCondition.Add(lSqlConditionInactive);
end;

procedure TActiveRangeParamsResult.ApplyParameters(const aQuery: ISqlPreparedBase);
begin
  if Length(fFromParamName) > 0 then
  begin
    var lParam := aQuery.ParamByName(fFromParamName);
    lParam.DataType := TFieldType.ftDate;
    lParam.Value := fActiveFrom;
  end;
  if Length(fToParamName) > 0 then
  begin
    var lParam := aQuery.ParamByName(fToParamName);
    lParam.DataType := TFieldType.ftDate;
    lParam.Value := fActiveTo;
  end;
end;

{ TActiveRecordInfo }

procedure TActiveRecordInfo.Reset;
begin
  Self := default(TActiveRecordInfo);
end;

procedure TActiveRecordInfo.SetActive(const aValue: Boolean);
begin
  fActive := aValue;
  fInitialized := True;
end;

procedure TActiveRecordInfo.SetInactiveInfoStr(const aValue: string);
begin
  fInactiveInfoStr := aValue;
  fInitialized := True;
end;

end.
