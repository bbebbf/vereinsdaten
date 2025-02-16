unit RoleMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TRoleMapper = class(TSingletonObject<TKeyIndexStrings>)
  strict private
    class var fConnection: ISqlConnection;
  strict protected
    class function CreateNewInstance: TKeyIndexStrings; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;
  end;

implementation

uses DtoRole, SelectList, CrudConfigRole;

{ TRoleMapper }

class function TRoleMapper.CreateNewInstance: TKeyIndexStrings;
begin
  Result := TKeyIndexStrings.Create(
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

class procedure TRoleMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TKeyIndexStrings)
    begin
      aInstance.Invalidate;
    end
  );
end;

end.
