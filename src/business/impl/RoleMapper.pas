unit RoleMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TRoleMapper = class(TSingletonObject<TRoleMapper>)
  strict private
    class var fConnection: ISqlConnection;
    var
      fData: TKeyIndexStrings;
  strict protected
    class function CreateNewInstance: TRoleMapper; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;

    constructor Create;
    destructor Destroy; override;
    property Data: TKeyIndexStrings read fData;
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
  fData := TKeyIndexStrings.Create(
      function(var aData: TKeyIndexStringsData): Boolean
      begin
        Result := True;
        var lListConfig: ISelectList<TDtoRole> := TCrudConfigRole.Create;
        aData := TKeyIndexStringsData.Create;
        try
          aData.BeginUpdate;
          var lSqlResult := fConnection.GetSelectResult(lListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoRole);
            lListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.AddMappedString(lRecord.Id, lRecord.ToString);
          end;
        finally
          aData.EndUpdate;
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

