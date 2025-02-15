unit UnitMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TUnitMapper = class(TSingletonObject<TActiveKeyIndexStringsLoader>)
  strict private
    class var fConnection: ISqlConnection;
    class function CreateNewInstance: TActiveKeyIndexStringsLoader; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;
  end;

implementation

uses DtoUnit, SelectList, CrudConfigUnit;

{ TUnitMapper }

class function TUnitMapper.CreateNewInstance: TActiveKeyIndexStringsLoader;
begin
  Result := TActiveKeyIndexStringsLoader.Create(
      function(var aData: TActiveKeyIndexStrings): Boolean
      begin
        Result := True;
        var lListConfig: ISelectList<TDtoUnit> := TCrudConfigUnit.Create;
        aData := TActiveKeyIndexStrings.Create;
        var lSqlResult := fConnection.GetSelectResult(lListConfig.GetSelectListSQL);
        while lSqlResult.Next do
        begin
          var lRecord := default(TDtoUnit);
          lListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
          aData.AddString(lRecord.Id, lRecord.Active, lRecord.ToString);
        end;
    end
    );
end;

class procedure TUnitMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TActiveKeyIndexStringsLoader)
    begin
      aInstance.Invalidate;
    end
  );
end;

end.

