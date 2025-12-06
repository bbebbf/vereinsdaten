unit Exporter.Params.Tools;

interface

uses Data.DB, SqlConnection, SqlConditionBuilder;

type
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
    fActiveFrom: TDate;
    fActiveFromSet: Boolean;
    fActiveTo: TDate;
    fActiveToSet: Boolean;
    procedure SetActiveFrom(const aValue: TDate);
    procedure SetActiveTo(const aValue: TDate);
  private
    function IsActiveAndInactiveMixed: Boolean;
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aEntityTitle: string);
    function Get(const aTableAlias: string = ''; const aParamsPrefix: string = ''): IActiveRangeParamsResult;
    procedure ClearActiveRange;
    function GetReadableCondition: string;
    function GetMixedActiveRangeText(const aDataSet: TDataSet): string;
    property EntityTitle: string read fEntityTitle;
    property Kind: TActiveRangeParamsKind read fKind write fKind;
    property ActiveFrom: TDate read fActiveFrom write SetActiveFrom;
    property ActiveFromSet: Boolean read fActiveFromSet;
    property ActiveTo: TDate read fActiveTo write SetActiveTo;
    property ActiveToSet: Boolean read fActiveToSet;
  end;

implementation

uses System.SysUtils, System.DateUtils, StringTools, InterfacedBase, RangeTools, Nullable;

type
  TActiveRangeParamsResult = class(TInterfacedBase, IActiveRangeParamsResult)
  strict private
    fActiveColumnName: string;
    fActiveFromColumnName: string;
    fActiveToColumnName: string;
    fTableAlias: string;
    fParamsPrefix: string;
    fKind: TActiveRangeParamsKind;
    fActiveFrom: TDate;
    fActiveFromSet: Boolean;
    fActiveTo: TDate;
    fActiveToSet: Boolean;
    fFromParamName: string;
    fToParamName: string;
    function GetSqlCondition: ISqlConditionNode;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName,
      aTableAlias, aParamsPrefix: string;
      const aKind: TActiveRangeParamsKind;
      const aActiveFromSet, aActiveToSet: Boolean;
      const aActiveFrom, aActiveTo: TDate);
  end;

{ TActiveRangeParams }

constructor TActiveRangeParams.Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aEntityTitle: string);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fEntityTitle := aEntityTitle;
  fKind := TActiveRangeParamsKind.ActiveEntries;
end;

procedure TActiveRangeParams.ClearActiveRange;
begin
  fActiveFrom := 0;
  fActiveFromSet := False;
  fActiveTo := 0;
  fActiveToSet := False;
end;

function TActiveRangeParams.Get(const aTableAlias, aParamsPrefix: string): IActiveRangeParamsResult;
begin
  Result := TActiveRangeParamsResult.Create(fActiveColumnName,
    fActiveFromColumnName, fActiveToColumnName, aTableAlias, aParamsPrefix,
    fKind, fActiveFromSet, fActiveToSet, fActiveFrom, fActiveTo);
end;

function TActiveRangeParams.GetMixedActiveRangeText(const aDataSet: TDataSet): string;
begin
  Result := '';
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit;
  if aDataSet.FieldByName(fActiveColumnName).AsBoolean then
    Exit;

  var lNullableFrom := TNullable<TDate>.New;
  var lNullableTo := TNullable<TDate>.New;
  var lFieldActiveFrom := aDataSet.FieldByName(fActiveFromColumnName);
  var lFieldActiveTo := aDataSet.FieldByName(fActiveToColumnName);
  if not lFieldActiveFrom.IsNull then
    lNullableFrom.Value := lFieldActiveFrom.AsDateTime;
  if not lFieldActiveTo.IsNull then
    lNullableTo.Value := lFieldActiveTo.AsDateTime;
  Result := 'aktiv ' + TRangeTools.GetDateRangeString(lNullableFrom, lNullableTo);
end;

function TActiveRangeParams.GetReadableCondition: string;
begin
  Result := '';
  if fKind = TActiveRangeParamsKind.Unknown then
    Exit;
  if fKind = TActiveRangeParamsKind.AllEntries then
    Exit('Alle ' + fEntityTitle);
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit('Nur inaktive ' + fEntityTitle);
  if fKind = TActiveRangeParamsKind.ActiveEntries then
  begin
    var lFromDate := TNullable<TDate>.New;
    if fActiveFromSet then
      lFromDate.Value := fActiveFrom;
    var lToDate := TNullable<TDate>.New;
    if fActiveToSet then
      lToDate.Value := fActiveTo;

    var lRangeText := TRangeTools.GetDateRangeString(lFromDate, lToDate);
    if Length(lRangeText) > 0 then
    begin
      Result := 'Aktive und inaktive ' + fEntityTitle + ' (aktiv ' + lRangeText + ')';
    end
    else
    begin
      Result := 'Aktive ' + fEntityTitle;
    end;
  end;
end;

function TActiveRangeParams.IsActiveAndInactiveMixed: Boolean;
begin
  Result := (fKind = TActiveRangeParamsKind.ActiveEntries) and (fActiveFromSet or fActiveToSet);
end;

procedure TActiveRangeParams.SetActiveFrom(const aValue: TDate);
begin
  fActiveFrom := aValue;
  if CompareDate(fActiveFrom, fActiveTo) > 0 then
    fActiveTo := fActiveFrom;
  fActiveFromSet := True;
end;

procedure TActiveRangeParams.SetActiveTo(const aValue: TDate);
begin
  fActiveTo := aValue;
  if CompareDate(fActiveFrom, fActiveTo) > 0 then
    fActiveFrom := fActiveTo;
  fActiveToSet := True;
end;

{ TActiveRangeParamsResult }

constructor TActiveRangeParamsResult.Create(
  const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aTableAlias, aParamsPrefix: string;
  const aKind: TActiveRangeParamsKind;
  const aActiveFromSet, aActiveToSet: Boolean;
  const aActiveFrom, aActiveTo: TDate);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fTableAlias := aTableAlias;
  fParamsPrefix := aParamsPrefix;
  fKind := aKind;
  fActiveFromSet := aActiveFromSet;
  fActiveToSet := aActiveToSet;
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

  if not fActiveFromSet and not fActiveToSet then
    Exit(lSqlCondition);

  var lParamsPrefix := fParamsPrefix;
  if Length(lParamsPrefix) = 0 then
    lParamsPrefix := fTableAlias + '_p';

  var lFromColumn := TStringTools.Combine(fTableAlias, '.', fActiveFromColumnName);
  var lToColumn := TStringTools.Combine(fTableAlias, '.', fActiveToColumnName);

  var lRangeCondition := TSqlConditionBuilder.CreateOr;
  if fActiveFromSet and fActiveToSet then
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
  else if fActiveFromSet then
  begin
    fFromParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveFromColumnName);

    lRangeCondition.AddAnd
      .AddIsNotNull(lToColumn)
      .AddLessOrEqualThan.Left(':' + fFromParamName).Right(lToColumn);
  end
  else if fActiveToSet then
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

end.
