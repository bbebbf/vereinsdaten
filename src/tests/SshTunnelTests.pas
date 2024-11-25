 unit SshTunnelTests;

interface

uses
  DUnitX.TestFramework;

type
  [TestFixture]
  TSshTunnelTests = class
  public
    [Test]
    [Ignore]
    procedure Test1;
  end;

implementation

{ TSshTunnelTests }

procedure TSshTunnelTests.Test1;
begin

end;

initialization
  TDUnitX.RegisterTestFixture(TSshTunnelTests);

end.
