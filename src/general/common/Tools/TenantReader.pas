unit TenantReader;

interface

uses Singleton, SqlConnection, DtoTenant;

type
  TTenantReader = class(TSingletonObject<TTenantReader>)
  strict private
    class var fConnection: ISqlConnection;
    var
      fTenant: TDtoTenant;
      fFound: Boolean;
      procedure ReadTenant;
      function GetTenant: TDtoTenant;
      function GetFound: Boolean;
  strict protected
    class function CreateNewInstance: TTenantReader; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;
    procedure Reset;
    property Found: Boolean read GetFound;
    property Tenant: TDtoTenant read GetTenant;
  end;

implementation

{ TTenantReader }

uses System.SysUtils;

function TTenantReader.GetTenant: TDtoTenant;
begin
  ReadTenant;
  Result := fTenant;
end;

class function TTenantReader.CreateNewInstance: TTenantReader;
begin
  Result := TTenantReader.Create;
  Result.Connection := fConnection;
end;

class procedure TTenantReader.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TTenantReader)
    begin
      aInstance.Reset;
    end
  );
end;

function TTenantReader.GetFound: Boolean;
begin
  ReadTenant;
  Result := fFound;
end;

procedure TTenantReader.ReadTenant;
begin
  if fFound then
    Exit;

  fTenant := default(TDtoTenant);
  if not Assigned(fConnection) then
    Exit;

  var lSqlResult := fConnection.GetSelectResult('select * from tenant');
  if lSqlResult.Next then
  begin
    fTenant.Id := lSqlResult.FieldByName('ten_id').AsInteger;
    fTenant.Title := lSqlResult.FieldByName('ten_title').AsString;
  end;
  fFound := True;
end;

procedure TTenantReader.Reset;
begin
  fFound := False;
end;

end.
