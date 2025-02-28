unit RoleMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TRoleMapper = class(TSingletonObject<TRoleMapper>)
  strict private
    class var fConnection: ISqlConnection;
    var
      fData: TActiveKeyIndexStringsLoader;
  strict protected
    class function CreateNewInstance: TRoleMapper; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;

    constructor Create;
    destructor Destroy; override;
    property Data: TActiveKeyIndexStringsLoader read fData;
  end;

implementation

uses DtoRole, SelectList, CrudConfigRole;

{ TRoleMapper }

class function TRoleMapper.CreateNewInstance: TRoleMapper;
begin
  Result := TRoleMapper.Create;
end;

class procedure TRoleMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TRoleMapper)
    begin
      aInstance.Data.Invalidate;
    end
  );
end;

constructor TRoleMapper.Create;
begin
  inherited Create;
  fData := TActiveKeyIndexStringsLoader.Create(
      function(var aData: TActiveKeyIndexStrings): Boolean
      begin
        Result := True;
        var lListConfig: ISelectList<TDtoRole> := TCrudConfigRole.Create;
        aData := TActiveKeyIndexStrings.Create;
        var lSqlResult := fConnection.GetSelectResult(lListConfig.GetSelectListSQL);
        while lSqlResult.Next do
        begin
          var lRecord := default(TDtoRole);
          lListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
          aData.AddString(lRecord.Id, lRecord.Active, lRecord.ToString);
        end;
      end
    );
end;

destructor TRoleMapper.Destroy;
begin
  fData.Free;
  inherited;
end;

end.

