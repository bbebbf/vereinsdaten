unit Joiner.Tests;

interface

uses
  DUnitX.TestFramework, System.SysUtils, Joiner;

type
  [TestFixture]
  TJoinerTests = class
  strict private
    function CreateJoiner<T>(const aLimit:Integer; const aLeading, aSeparator, aTrailing: string): TJoiner<T>;
    function GetArray(const aInput: string): TArray<string>;
    procedure AssertStrArrays(const aExpected, aActual: TArray<string>);
  public
    [TestCase('0', '1,a,,e,a/b,aae/abe')]
    [TestCase('1', '0,,,,a/b,ab')]
    [TestCase('2', '0,a,,e,1/2,a12e')]
    procedure JoinStrings(const aLimit:Integer; const aLeading, aSeparator, aTrailing, aInput, aExpected: string);

    [TestCase('1', '0,a,,e,1/2,a12e')]
    procedure JoinIntegers(const aLimit:Integer; const aLeading, aSeparator, aTrailing, aInput, aExpected: string);
  end;

implementation

uses System.StrUtils;

{ TJoinerTests }

procedure TJoinerTests.JoinIntegers(const aLimit: Integer; const aLeading, aSeparator, aTrailing, aInput,
  aExpected: string);
begin
  var lInputArray := GetArray(aInput);
  var lInputArrayInteger: TArray<Integer>;
  SetLength(lInputArrayInteger, Length(lInputArray));
  for var i := Low(lInputArrayInteger) to High(lInputArrayInteger) do
  begin
    var lInputInt: Integer;
    if TryStrToInt(lInputArray[i], lInputInt) then
      lInputArrayInteger[i] := lInputInt
    else
      Assert.Fail('Input value is not an integer.');
  end;

  var lExpectedArray := GetArray(aExpected);

  var lJoiner := CreateJoiner<Integer>(aLimit, aLeading, aSeparator, aTrailing);
  try
    lJoiner.Add(lInputArrayInteger);
    AssertStrArrays(lExpectedArray, lJoiner.Strings);
  finally
    lJoiner.Free;
  end;
end;

procedure TJoinerTests.JoinStrings(const aLimit:Integer;
  const aLeading, aSeparator, aTrailing, aInput, aExpected: string);
begin
  var lInputArray := GetArray(aInput);
  var lExpectedArray := GetArray(aExpected);

  var lJoiner := CreateJoiner<string>(aLimit, aLeading, aSeparator, aTrailing);
  try
    lJoiner.Add(lInputArray);
    AssertStrArrays(lExpectedArray, lJoiner.Strings);
  finally
    lJoiner.Free;
  end;
end;

function TJoinerTests.CreateJoiner<T>(const aLimit: Integer; const aLeading, aSeparator,
  aTrailing: string): TJoiner<T>;
begin
  Result := TJoiner<T>.Create;
  Result.LineElementLimit := aLimit;
  Result.LineLeading := aLeading;
  Result.LineTrailing := aTrailing;
  Result.ElementSeparator := aSeparator;
end;

procedure TJoinerTests.AssertStrArrays(const aExpected, aActual: TArray<string>);
begin
  Assert.AreEqual(Length(aExpected), Length(aActual), 'Array lengths different.');
  for var i := Low(aExpected) to High(aExpected) do
    Assert.AreEqual(aExpected[i], aActual[i]);
end;

function TJoinerTests.GetArray(const aInput: string): TArray<string>;
begin
  Result := aInput.Split(['/']);
end;

initialization
  TDUnitX.RegisterTestFixture(TJoinerTests);
  TDUnitX.Options.ExitBehavior := TDUnitXExitBehavior.Pause;


end.
