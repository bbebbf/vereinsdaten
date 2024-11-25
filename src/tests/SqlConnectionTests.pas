unit SqlConnectionTests;

interface

uses
  DUnitX.TestFramework,
  SqlConnection;

type
  [TestFixture]
  TSqlConnectionTests = class
  strict private
    function CreateConnection: ISqlConnection;
  public
    [Test]
    procedure Test1;
    [Test]
    [Ignore]
    procedure Test2;
  end;

implementation

uses Transaction, MySqlConnection, CrudAccessor;

procedure TSqlConnectionTests.Test1;
begin
  var lCrudAc := TCrudAccessorUpdate.Create(CreateConnection, 'person_address', ['person_id']);
  try
    lCrudAc.SetValue('person_id', 11);
    lCrudAc.SetValue('adr_id', 1);
    lCrudAc.Update();
  finally
    lCrudAc.Free;
  end;
end;

procedure TSqlConnectionTests.Test2;
begin
  var lResultSet := CreateConnection.GetSelectResult('select * from person');
  while lResultSet.Next do
  begin
    var lId := lResultSet.Fields[0].AsLargeInt;
    var lText := lResultSet.Fields[1].AsString;
  end;
end;

function TSqlConnectionTests.CreateConnection: ISqlConnection;
begin
  Result := TMySqlConnection.Create;
  Result.Parameters.Host := 'localhost';
  Result.Parameters.Port := 8306;
  Result.Parameters.Databasename := 'vd_db';
  Result.Parameters.Username := 'vd_user';
  Result.Parameters.Password := 'vd_pwd';
end;


initialization
  TDUnitX.RegisterTestFixture(TSqlConnectionTests);

end.
