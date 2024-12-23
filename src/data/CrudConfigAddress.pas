unit CrudConfigAddress;

interface

uses System.SysUtils, CrudConfig, CrudAccessor, SqlConnection, SelectList, DtoAddress;

type
  TCrudConfigAddress = class(TInterfacedObject, ICrudConfig<TDtoAddress, UInt32>, ISelectList<TDtoAddress>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoAddress);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoAddress; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoAddress);
    function GetSelectListSQL: string;
    function GetRecordIdentity(const aRecord: TDtoAddress): UInt32;
  end;

implementation

{ TCrudConfigAddress }

function TCrudConfigAddress.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

function TCrudConfigAddress.GetSelectListSQL: string;
begin
  Result := 'select * from address order by adr_street';
end;

function TCrudConfigAddress.GetSelectRecordSQL: string;
begin
  Result := 'select * from address where adr_id = :Id';
end;

function TCrudConfigAddress.GetTablename: string;
begin
  Result := 'address';
end;

function TCrudConfigAddress.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigAddress.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoAddress);
begin
  aRecord.Id := aSqlResult.FieldByName('adr_id').AsLongWord;
  aRecord.Street := aSqlResult.FieldByName('adr_street').AsString;
  aRecord.Postalcode := aSqlResult.FieldByName('adr_postalcode').AsString;
  aRecord.City := aSqlResult.FieldByName('adr_city').AsString;
end;

function TCrudConfigAddress.GetRecordIdentity(const aRecord: TDtoAddress): UInt32;
begin
  Result := aRecord.Id;
end;

procedure TCrudConfigAddress.SetValues(const aRecord: TDtoAddress; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('adr_id', aRecord.Id);
  aAccessor.SetValue('adr_street', aRecord.Street);
  aAccessor.SetValue('adr_postalcode', aRecord.Postalcode);
  aAccessor.SetValue('adr_city', aRecord.City);
end;

procedure TCrudConfigAddress.SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('adr_id', aRecordIdentity);
end;

procedure TCrudConfigAddress.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigAddress.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoAddress);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
