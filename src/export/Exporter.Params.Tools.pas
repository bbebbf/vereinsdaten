unit Exporter.Params.Tools;

interface

uses SqlConnection, SqlConditionBuilder;

type
  TActiveRangeParamsKind = (Unknown, AllEntries, ActiveEntries, InactiveEntriesOnly);

  IActiveRangeParamsResult = interface
    ['{377BD875-A7CF-4528-BDAD-2C242C01E7CD}']
    function GetSqlCondition(const aConditionStart: TSqlConditionStart = TSqlConditionStart.EmptyStart): string;
    function GetReadableCondition(const aEntryTitle: string): string;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  end;

  TActiveRangeParams = class
  strict private
    fActiveColumnName: string;
    fActiveFromColumnName: string;
    fActiveToColumnName: string;
    fKind: TActiveRangeParamsKind;
    fActiveFrom: TDate;
    fActiveFromSet: Boolean;
    fActiveTo: TDate;
    fActiveToSet: Boolean;
    procedure SetActiveFrom(const aValue: TDate);
    procedure SetActiveTo(const aValue: TDate);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName: string);
    function Get(const aTableAlias: string = ''; const aParamsPrefix: string = ''): IActiveRangeParamsResult;
    procedure ClearActiveRange;
    property Kind: TActiveRangeParamsKind read fKind write fKind;
    property ActiveFrom: TDate read fActiveFrom write SetActiveFrom;
    property ActiveFromSet: Boolean read fActiveFromSet;
    property ActiveTo: TDate read fActiveTo write SetActiveTo;
    property ActiveToSet: Boolean read fActiveToSet;
  end;

implementation

uses System.DateUtils, Data.DB, StringTools, InterfacedBase;

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
    function GetSqlCondition(const aConditionStart: TSqlConditionStart): string;
    function GetReadableCondition(const aEntryTitle: string): string;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName,
      aTableAlias, aParamsPrefix: string;
      const aKind: TActiveRangeParamsKind;
      const aActiveFromSet, aActiveToSet: Boolean;
      const aActiveFrom, aActiveTo: TDate);
  end;

{ TActiveRangeParams }

constructor TActiveRangeParams.Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName: string);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
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

function TActiveRangeParamsResult.GetSqlCondition(const aConditionStart: TSqlConditionStart): string;
begin
  fFromParamName := '';
  fToParamName := '';
  if fKind in [TActiveRangeParamsKind.Unknown, TActiveRangeParamsKind.AllEntries] then
    Exit('');

  var lActiveColumn := TStringTools.Combine(fTableAlias, '.', fActiveColumnName);
  var lSqlCondition := TSqlConditionBuilder.CreateOr;

  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
  begin
    lSqlCondition.AddEquals
      .Left(lActiveColumn)
      .Right('0');
    Exit(lSqlCondition.GetConditionString(aConditionStart));
  end;

  lSqlCondition.AddEquals
    .Left(lActiveColumn)
    .Right('1');

  if not fActiveFromSet and not fActiveToSet then
    Exit(lSqlCondition.GetConditionString(aConditionStart));

  var lParamsPrefix := fParamsPrefix;
  if Length(lParamsPrefix) = 0 then
    lParamsPrefix := fTableAlias + '_p';

  var lFromColumn := TStringTools.Combine(fTableAlias, '.', fActiveFromColumnName);
  var lToColumn := TStringTools.Combine(fTableAlias, '.', fActiveToColumnName);

  var lFromInRange := TSqlConditionBuilder.CreateAnd;
  var lToInRange := TSqlConditionBuilder.CreateAnd;
  var lNoOverlappingRange := TSqlConditionBuilder.CreateOr;

  if fActiveFromSet then
  begin
    fFromParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveFromColumnName);

    lFromInRange.AddGreaterOrEqualThan.Left(lFromColumn).Right(':' +fFromParamName);
    lToInRange.AddGreaterOrEqualThan.Left(lToColumn).Right(':' +fFromParamName);
    lNoOverlappingRange.AddAnd
      .AddLessThan.Left(lFromColumn).Right(':' + fFromParamName)
      .Parent
      .AddLessThan.Left(lToColumn).Right(':' + fFromParamName);
  end;
  if fActiveToSet then
  begin
    fToParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveToColumnName);

    lFromInRange.AddLessOrEqualThan.Left(lFromColumn).Right(':' +fToParamName);
    lToInRange.AddLessOrEqualThan.Left(lToColumn).Right(':' +fToParamName);
    lNoOverlappingRange.AddAnd
      .AddGreaterThan.Left(lFromColumn).Right(':' + fToParamName)
      .Parent
      .AddGreaterThan.Left(lToColumn).Right(':' + fToParamName);
  end;

  var lSqlConditionInactive := TSqlConditionBuilder.CreateAnd;
  lSqlConditionInactive
    .AddEquals.Left(lActiveColumn).Right('0')
    .Parent
    .AddOr
      .AddAnd
        .AddIsNotNull(lFromColumn)
        .AddIsNotNull(lToColumn)
        .AddNot.Add(lNoOverlappingRange)
      .Parent
      .AddAnd
        .AddIsNotNull(lFromColumn)
        .AddIsNull(lToColumn)
        .Add(lFromInRange)
      .Parent
      .AddAnd
        .AddIsNull(lFromColumn)
        .AddIsNotNull(lToColumn)
        .Add(lToInRange);

  Result := lSqlCondition.Add(lSqlConditionInactive).GetConditionString(aConditionStart);
end;

function TActiveRangeParamsResult.GetReadableCondition(const aEntryTitle: string): string;
begin
  Result := '';
  if fKind = TActiveRangeParamsKind.Unknown then
    Exit;
  if fKind = TActiveRangeParamsKind.AllEntries then
    Exit('Alle ' + aEntryTitle);
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit('Nur inaktive ' + aEntryTitle);
  if fKind = TActiveRangeParamsKind.ActiveEntries then
  begin
  end;
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
