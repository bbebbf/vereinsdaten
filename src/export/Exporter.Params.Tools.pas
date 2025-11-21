unit Exporter.Params.Tools;

interface

uses SqlConnection;

type
  TActiveRangeParamsKind = (Unknown, AllEntries, ActiveEntries, InactiveEntriesOnly);

  IActiveRangeParamsResult = interface
    ['{377BD875-A7CF-4528-BDAD-2C242C01E7CD}']
    function GetSqlCondition(const aConjunction: string = ''): string;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  end;

  TActiveRangeParams = class
  strict private
    fActiveColumnName: string;
    fActiveFromColumnName: string;
    fActiveToColumnName: string;
    fKind: TActiveRangeParamsKind;
    fActiveRangeSet: Boolean;
    fActiveFrom: TDate;
    fActiveTo: TDate;
    procedure SetActiveFrom(const aValue: TDate);
    procedure SetActiveTo(const aValue: TDate);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName: string);
    function Get(const aTableAlias: string = ''; const aParamsPrefix: string = ''): IActiveRangeParamsResult;
    procedure ClearActiveRange;
    property Kind: TActiveRangeParamsKind read fKind write fKind;
    property ActiveRangeSet: Boolean read fActiveRangeSet;
    property ActiveFrom: TDate read fActiveFrom write SetActiveFrom;
    property ActiveTo: TDate read fActiveTo write SetActiveTo;
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
    fActiveRangeSet: Boolean;
    fActiveFrom: TDate;
    fActiveTo: TDate;
    fFromParamName: string;
    fToParamName: string;
    function GetSqlCondition(const aConjunction: string): string;
    procedure ApplyParameters(const aQuery: ISqlPreparedBase);
  public
    constructor Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName,
      aTableAlias, aParamsPrefix: string;
      const aKind: TActiveRangeParamsKind;
      const aActiveRangeSet: Boolean;
      const aActiveSince, aActiveUntil: TDate);
  end;

{ TActiveRangeParams }

constructor TActiveRangeParams.Create(const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName: string);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fKind := TActiveRangeParamsKind.AllEntries;
end;

procedure TActiveRangeParams.ClearActiveRange;
begin
  fActiveFrom := 0;
  fActiveTo := 0;
  fActiveRangeSet := False;
end;

function TActiveRangeParams.Get(const aTableAlias, aParamsPrefix: string): IActiveRangeParamsResult;
begin
  Result := TActiveRangeParamsResult.Create(fActiveColumnName,
    fActiveFromColumnName, fActiveToColumnName, aTableAlias, aParamsPrefix,
    fKind, fActiveRangeSet, fActiveFrom, fActiveTo);
end;

procedure TActiveRangeParams.SetActiveFrom(const aValue: TDate);
begin
  fActiveFrom := aValue;
  if CompareDate(fActiveFrom, fActiveTo) > 0 then
    fActiveTo := fActiveFrom;
  fActiveRangeSet := True;
end;

procedure TActiveRangeParams.SetActiveTo(const aValue: TDate);
begin
  fActiveTo := aValue;
  if CompareDate(fActiveFrom, fActiveTo) > 0 then
    fActiveFrom := fActiveTo;
  fActiveRangeSet := True;
end;

{ TActiveRangeParamsResult }

constructor TActiveRangeParamsResult.Create(
  const aActiveColumnName, aActiveFromColumnName, aActiveToColumnName, aTableAlias, aParamsPrefix: string;
  const aKind: TActiveRangeParamsKind;
  const aActiveRangeSet: Boolean;
  const aActiveSince, aActiveUntil: TDate);
begin
  inherited Create;
  fActiveColumnName := aActiveColumnName;
  fActiveFromColumnName := aActiveFromColumnName;
  fActiveToColumnName := aActiveToColumnName;
  fTableAlias := aTableAlias;
  fParamsPrefix := aParamsPrefix;
  fKind := aKind;
  fActiveRangeSet := aActiveRangeSet;
  fActiveFrom := aActiveSince;
  fActiveTo := aActiveUntil;
end;

function TActiveRangeParamsResult.GetSqlCondition(const aConjunction: string): string;
begin
  fFromParamName := '';
  fToParamName := '';
  if fKind in [TActiveRangeParamsKind.Unknown, TActiveRangeParamsKind.AllEntries] then
    Exit('');

  var lActiveColumn := TStringTools.Combine(fTableAlias, '.', fActiveColumnName);
  if fKind = TActiveRangeParamsKind.InactiveEntriesOnly then
    Exit(aConjunction + ' (' + lActiveColumn + ' = 0)');

  var lSqlCondition := lActiveColumn + ' = 1';

  if not fActiveRangeSet then
    Exit(aConjunction + ' (' + lSqlCondition + ')');

  var lParamsPrefix := fParamsPrefix;
  if Length(lParamsPrefix) = 0 then
    lParamsPrefix := fTableAlias + '_p';

  var lFromColumn := TStringTools.Combine(fTableAlias, '.', fActiveFromColumnName);
  var lToColumn := TStringTools.Combine(fTableAlias, '.', fActiveToColumnName);
  fFromParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveFromColumnName);
  fToParamName := TStringTools.Combine(lParamsPrefix, '_', fActiveToColumnName);

  var lFromInRange := '(' + lFromColumn + ' >= :' + fFromParamName +
    ' and ' + lFromColumn + ' <= :' + fToParamName + ')';
  var lToInRange := '(' + lToColumn + ' >= :' + fFromParamName +
    ' and ' + lToColumn + ' <= :' + fToParamName + ')';
  var lNoOverlappingRange := '(' + lFromColumn + ' < :' + fFromParamName + ' and ' + lToColumn + ' < :' + fFromParamName + ')' +
    ' or (' + lFromColumn + ' > :' + fToParamName + ' and ' + lToColumn + ' > :' + fToParamName + ')';

  var lSqlConditionInactive := '(' + lActiveColumn + ' = 0 and (' +
         '(' + lFromColumn + ' is not null and ' + lToColumn + ' is not null and not (' + lNoOverlappingRange + '))' +
      'or (' + lFromColumn + ' is not null and ' + lToColumn + ' is null and (' + lFromInRange + '))' +
      'or (' + lFromColumn + ' is null and ' + lToColumn + ' is not null and (' + lToInRange + '))' +
    '))';
  Result := aConjunction + ' (' + lSqlCondition + ' or ' + lSqlConditionInactive + ')';
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
