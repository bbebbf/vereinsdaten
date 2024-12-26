unit CrudConfigUnit;

interface

uses InterfacedBase, CrudConfig, SelectList, SqlConnection, CrudAccessor, DtoUnit;

type
  TCrudConfigUnit = class(TInterfacedBase, ICrudConfig<TDtoUnit, UInt32>, ISelectList<TDtoUnit>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoUnit; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoUnit);
    function GetRecordIdentity(const aRecord: TDtoUnit): UInt32;

    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoUnit);
    function GetSelectListSQL: string;
  end;

implementation

{ TCrudConfigUnit }

function TCrudConfigUnit.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

procedure TCrudConfigUnit.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoUnit);
begin
  aData.Id := aSqlResult.FieldByName('unit_id').AsLargeInt;
  aData.Name := aSqlResult.FieldByName('unit_name').AsString;
  aData.Active := aSqlResult.FieldByName('unit_active').AsBoolean;
  aData.ActiveSince := aSqlResult.FieldByName('unit_active_since').AsDateTime;
  aData.ActiveUntil := aSqlResult.FieldByName('unit_active_until').AsDateTime;
end;

function TCrudConfigUnit.GetRecordIdentity(const aRecord: TDtoUnit): UInt32;
begin
  Result := aRecord.Id;
end;

function TCrudConfigUnit.GetSelectListSQL: string;
begin
  Result := 'select * from unit order by unit_name';
end;

function TCrudConfigUnit.GetSelectRecordSQL: string;
begin
  Result := 'select * from unit where unit_id = :Id';
end;

function TCrudConfigUnit.GetTablename: string;
begin
  Result := 'unit';
end;

function TCrudConfigUnit.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigUnit.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigUnit.SetValues(const aRecord: TDtoUnit; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('unit_id', aRecord.Id);
  aAccessor.SetValue('unit_name', aRecord.Name);
  aAccessor.SetValue('unit_active', aRecord.Active);
  aAccessor.SetValueZeroAsNull('unit_active_since', aRecord.ActiveSince);
  aAccessor.SetValueZeroAsNull('unit_active_until', aRecord.ActiveUntil);
end;

procedure TCrudConfigUnit.SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('unit_id', aRecordIdentity);
end;

procedure TCrudConfigUnit.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoUnit);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
