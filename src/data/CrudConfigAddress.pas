unit CrudConfigAddress;

interface

uses System.SysUtils, CrudConfig, CrudAccessor, SqlConnection, DtoAddress;

type
  TCrudConfigAddress = class(TInterfacedObject, ICrudConfig<TDtoAddress, Int32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectSqlList: string;
    function GetSelectSqlRecord: string;
    procedure SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoAddress);
    function IsNewRecord(const aRecord: TDtoAddress): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoAddress; const aAccessor: TCrudAccessorBase);
    procedure SetParametersForLoad(const aRecordIdentity: Int32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: Int32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoAddress);
  end;

implementation

{ TCrudConfigAddress }

function TCrudConfigAddress.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

function TCrudConfigAddress.GetSelectSqlList: string;
begin
  Result := 'select * from address order by adr_street';
end;

function TCrudConfigAddress.GetSelectSqlRecord: string;
begin
  Result := 'select * from address where adr_id = :Id';

end;

function TCrudConfigAddress.GetTablename: string;
begin
  Result := 'address';
end;

function TCrudConfigAddress.IsNewRecord(const aRecord: TDtoAddress): TCrudConfigNewRecordResponse;
begin
  if aRecord.Id = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigAddress.SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoAddress);
begin
  aRecord.Id := aSqlResult.FieldByName('adr_id').AsLargeInt;
  aRecord.Street := aSqlResult.FieldByName('adr_street').AsString;
  aRecord.Postalcode := aSqlResult.FieldByName('adr_postalcode').AsString;
  aRecord.City := aSqlResult.FieldByName('adr_city').AsString;
end;

procedure TCrudConfigAddress.SetValues(const aRecord: TDtoAddress; const aAccessor: TCrudAccessorBase);
begin
  aAccessor.SetValue('adr_street', aRecord.Street);
  aAccessor.SetValue('adr_postalcode', aRecord.Postalcode);
  aAccessor.SetValue('adr_city', aRecord.City);
end;

procedure TCrudConfigAddress.SetValuesForDelete(const aRecordIdentity: Int32; const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('adr_id', aRecordIdentity);
end;

procedure TCrudConfigAddress.SetParametersForLoad(const aRecordIdentity: Int32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigAddress.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoAddress);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
