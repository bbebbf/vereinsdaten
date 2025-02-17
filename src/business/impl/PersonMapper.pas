unit PersonMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TPersonMapper = class(TSingletonObject<TPersonMapper>)
  strict private
    class var fConnection: ISqlConnection;
    var
      fData: TActiveKeyIndexStringsLoader;
  strict protected
    class function CreateNewInstance: TPersonMapper; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;

    constructor Create;
    destructor Destroy; override;
    property Data: TActiveKeyIndexStringsLoader read fData;
  end;

implementation

uses DtoPerson, SelectList, CrudConfigPerson;

{ TPersonMapper }

class function TPersonMapper.CreateNewInstance: TPersonMapper;
begin
  Result := TPersonMapper.Create;
end;

class procedure TPersonMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TPersonMapper)
    begin
      aInstance.Data.Invalidate;
    end
  );
end;

constructor TPersonMapper.Create;
begin
  inherited Create;
  fData := TActiveKeyIndexStringsLoader.Create(
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

destructor TPersonMapper.Destroy;
begin
  fData.Free;
  inherited;
end;

end.
