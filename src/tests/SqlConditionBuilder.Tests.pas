unit SqlConditionBuilder.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, SqlConditionBuilder;

type
  [TestFixture]
  TSqlConditionBuilderTests = class
  strict private
    procedure AssertSqlConditionNode(const aExpectedCondition: string; const aNode: ISqlConditionNode);
  public
    [Test]
    procedure Build1();
    [Test]
    procedure BuildEmpty();
  end;

implementation

{ TSqlConditionBuilderTests }

procedure TSqlConditionBuilderTests.Build1;
begin
  var lNode := TSqlConditionBuilder.CreateAnd;
  lNode.AddRawSql('Hallo');
  var lUnitConditionsKind := lNode.AddOr;
  lUnitConditionsKind.AddIsNull.Value := 'u.a';
  lUnitConditionsKind.AddIsNotNull.Value := 'u.unit_kind';
  lUnitConditionsKind.AddEquals.Left('u.unit_kind').Right('2');
  AssertSqlConditionNode('(Hallo) and ((u.a is null) or (u.unit_kind is not null) or (u.unit_kind = 2))', lNode);
end;

procedure TSqlConditionBuilderTests.BuildEmpty;
begin
  var lNode := TSqlConditionBuilder.CreateAnd;
  var lUnitConditionsKind := lNode.AddOr;
  lUnitConditionsKind.AddIsNotNull;
  AssertSqlConditionNode('', lNode);
end;

procedure TSqlConditionBuilderTests.AssertSqlConditionNode(const aExpectedCondition: string;
  const aNode: ISqlConditionNode);
begin
  if Length(aExpectedCondition) = 0 then
  begin
    Assert.IsEmpty(aNode.GetConditionString(TSqlConditionStart.EmptyStart));
    Assert.IsEmpty(aNode.GetConditionString(TSqlConditionStart.WhereStart));
    Assert.IsEmpty(aNode.GetConditionString(TSqlConditionStart.OnStart));
    Assert.IsEmpty(aNode.GetConditionString(TSqlConditionStart.AndStart));
    Assert.IsEmpty(aNode.GetConditionString(TSqlConditionStart.OrStart));
  end
  else
  begin
    Assert.AreEqual(aExpectedCondition,
      aNode.GetConditionString(TSqlConditionStart.EmptyStart));
    Assert.AreEqual('where ' + aExpectedCondition,
      aNode.GetConditionString(TSqlConditionStart.WhereStart));
    Assert.AreEqual('on ' + aExpectedCondition,
      aNode.GetConditionString(TSqlConditionStart.OnStart));
    Assert.AreEqual('and (' + aExpectedCondition + ')',
      aNode.GetConditionString(TSqlConditionStart.AndStart));
    Assert.AreEqual('or (' + aExpectedCondition + ')',
      aNode.GetConditionString(TSqlConditionStart.OrStart));
  end;
end;

initialization
  TDUnitX.RegisterTestFixture(TSqlConditionBuilderTests);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;

end.
