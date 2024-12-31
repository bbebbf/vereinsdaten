unit TenantReader;

interface

uses SqlConnection, DtoTenant;

type
  TTenantReader = class
  strict private
    class var
      fInstance: TTenantReader;
      fConnection: ISqlConnection;

    var
    fTenant: TDtoTenant;
    fFound: Boolean;
    procedure ReadTenant;
    function GetTenant: TDtoTenant;
    function GetFound: Boolean;

    class function GetInstance: TTenantReader; static;
  public
    class destructor ClassDestroy;
    class property Connection: ISqlConnection read fConnection write fConnection;
    class property Instance: TTenantReader read GetInstance;

    property Found: Boolean read GetFound;
    property Tenant: TDtoTenant read GetTenant;
  end;

implementation

{ TTenantReader }

uses System.SysUtils;

class destructor TTenantReader.ClassDestroy;
begin
  fInstance.Free;
  fConnection := nil;
end;

function TTenantReader.GetTenant: TDtoTenant;
begin
  ReadTenant;
  Result := fTenant;
end;

function TTenantReader.GetFound: Boolean;
begin
  ReadTenant;
  Result := fFound;
end;

class function TTenantReader.GetInstance: TTenantReader;
begin
  if not Assigned(fInstance) then
    fInstance := TTenantReader.Create;
  Result := fInstance;
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

end.
