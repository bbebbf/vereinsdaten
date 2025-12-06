unit ActiveRangeParams.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, SqlConditionBuilder.Tests;

type
  [TestFixture]
  TActiveRangeParamsTests = class(TSqlConditionBuilderTests)
  public
    [Test]
    procedure ClosedInterval();
    [Test]
    procedure BeginToInfiniteInterval();
    [Test]
    procedure InfiniteToEndInterval();
  end;

implementation

uses SqlConditionBuilder, Exporter.Params.Tools;

{ TActiveRangeParamsTests }

procedure TActiveRangeParamsTests.ClosedInterval;
begin
  var lParams := TActiveRangeParams.Create('c_active', 'c_active_since', 'c_active_until', '');
  try
    lParams.Kind := TActiveRangeParamsKind.ActiveEntries;
    lParams.ActiveFrom := Now;
    lParams.ActiveTo := lParams.ActiveFrom;

    AssertSqlConditionNode(
    '(c_active = 1) or ((c_active = 0) and' +
    ' (((c_active_since is not null) and (c_active_until is not null) and (not ((:p_c_active_until < c_active_since) or (c_active_until < :p_c_active_since)))) or' +
    ' ((c_active_since is not null) and (c_active_until is null) and (:p_c_active_since <= c_active_since) and (c_active_since <= :p_c_active_until)) or' +
    ' ((c_active_since is null) and (c_active_until is not null) and (:p_c_active_since <= c_active_until) and (c_active_until <= :p_c_active_until))))',
      lParams.Get('', 'p').GetSqlCondition);
  finally
    lParams.Free;
  end;
end;

procedure TActiveRangeParamsTests.BeginToInfiniteInterval;
begin
  var lParams := TActiveRangeParams.Create('c_active', 'c_active_since', 'c_active_until', '');
  try
    lParams.Kind := TActiveRangeParamsKind.ActiveEntries;
    lParams.ActiveFrom := Now;

    AssertSqlConditionNode(
    '(c_active = 1) or ((c_active = 0) and' +
    ' ((c_active_until is not null) and (:p_c_active_since <= c_active_until)))',
      lParams.Get('', 'p').GetSqlCondition);
  finally
    lParams.Free;
  end;
end;

procedure TActiveRangeParamsTests.InfiniteToEndInterval;
begin
  var lParams := TActiveRangeParams.Create('c_active', 'c_active_since', 'c_active_until', '');
  try
    lParams.Kind := TActiveRangeParamsKind.ActiveEntries;
    lParams.ActiveTo := Now;

    AssertSqlConditionNode(
    '(c_active = 1) or ((c_active = 0) and' +
    ' ((c_active_since is not null) and (:p_c_active_until >= c_active_since)))',
      lParams.Get('', 'p').GetSqlCondition);
  finally
    lParams.Free;
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TActiveRangeParamsTests);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

end.
