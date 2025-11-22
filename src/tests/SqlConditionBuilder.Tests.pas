unit SqlConditionBuilder.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, Joiner;

type
  [TestFixture]
  TSqlConditionBuilderTests = class
  strict private
  public
    [Test]
    procedure Build1();
  end;

implementation

uses System.StrUtils, SqlConditionBuilder;


{ TSqlConditionBuilderTests }

procedure TSqlConditionBuilderTests.Build1;
begin
  var lUnitConditions := TSqlConditionBuilder.CreateAnd;
  lUnitConditions.Add.Value := 'Hallo';
  var lUnitConditionsKind := lUnitConditions.AddOr;
  lUnitConditionsKind.AddIsNotNull.Value := 'u.unit_kind';
  lUnitConditionsKind.AddEquals.SetLeftValue('u.unit_kind').SetRightValue('2');

  Assert.AreEqual('where (Hallo) and ((u.unit_kind is not null) or (u.unit_kind = 2))',
    lUnitConditions.GetConditionString(TSqlConditionKind.WhereKind));
end;

initialization
  TDUnitX.RegisterTestFixture(TSqlConditionBuilderTests);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

end.
