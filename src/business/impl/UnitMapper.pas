unit UnitMapper;

interface

uses Singleton, KeyIndexStrings, SqlConnection;

type
  TUnitMapper = class(TSingletonObject<TUnitMapper>)
  strict private
    class var fConnection: ISqlConnection;
    var
      fData: TActiveKeyIndexStringsLoader;
  strict protected
    class function CreateNewInstance: TUnitMapper; override;
  public
    class property Connection: ISqlConnection read fConnection write fConnection;
    class procedure Invalidate;

    constructor Create;
    destructor Destroy; override;
    property Data: TActiveKeyIndexStringsLoader read fData;
  end;

implementation

uses DtoUnit, SelectList, CrudConfigUnit;

{ TUnitMapper }

class function TUnitMapper.CreateNewInstance: TUnitMapper;
begin
  Result := TUnitMapper.Create;
end;

class procedure TUnitMapper.Invalidate;
begin
  CallProcIfInstanceAvailable(
    procedure(aInstance: TUnitMapper)
    begin
      aInstance.Data.Invalidate;
    end
  );
end;

constructor TUnitMapper.Create;
begin
  inherited Create;
  fData := TActiveKeyIndexStringsLoader.Create(
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

destructor TUnitMapper.Destroy;
begin
  fData.Free;
  inherited;
end;

end.
