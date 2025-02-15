unit PersonMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TPersonMapper = class(TSingletonObject<TActiveKeyIndexStringsLoader>)
  strict private
    class var fConnection: ISqlConnection;
  strict protected
    class function CreateNewInstance: TActiveKeyIndexStringsLoader; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;
  end;

implementation

uses DtoPerson, SelectList, CrudConfigPerson;

{ TPersonMapper }

class function TPersonMapper.CreateNewInstance: TActiveKeyIndexStringsLoader;
begin
  Result := TActiveKeyIndexStringsLoader.Create(
      function(var aData: TActiveKeyIndexStrings): Boolean
      begin
        Result := True;
        var lListConfig: ISelectList<TDtoPerson> := TCrudConfigPerson.Create;
        aData := TActiveKeyIndexStrings.Create;
        var lSqlResult := fConnection.GetSelectResult(lListConfig.GetSelectListSQL);
        while lSqlResult.Next do
        begin
          var lRecord := default(TDtoPerson);
          lListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
          aData.AddString(lRecord.NameId.Id, lRecord.Active, lRecord.ToString);
        end;
    end
    );
end;

class procedure TPersonMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TActiveKeyIndexStringsLoader)
    begin
      aInstance.Invalidate;
    end
  );
end;

end.
