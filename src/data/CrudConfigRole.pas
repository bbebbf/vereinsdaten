unit CrudConfigRole;

interface

uses InterfacedBase, SelectList, SqlConnection, CrudConfig, CrudAccessor, DtoRole;

type
  TCrudConfigRole = class(TInterfacedBase, ICrudConfig<TDtoRole, UInt32>, ISelectList<TDtoRole>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoRole; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoRole);
    function GetRecordIdentity(const aRecord: TDtoRole): UInt32;

    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoRole);
    function GetSelectListSQL: string;
  end;

implementation

{ TCrudConfigRole }

function TCrudConfigRole.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

procedure TCrudConfigRole.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoRole);
begin
  aData.Id := aSqlResult.FieldByName('role_id').AsLargeInt;
  aData.Name := aSqlResult.FieldByName('role_name').AsString;
  aData.Active := aSqlResult.FieldByName('role_active').AsBoolean;
  aData.Sorting := aSqlResult.FieldByName('role_sorting').AsInteger;
end;

function TCrudConfigRole.GetRecordIdentity(const aRecord: TDtoRole): UInt32;
begin
  Result := aRecord.Id;
end;

function TCrudConfigRole.GetSelectListSQL: string;
begin
  Result := 'select * from role order by role_sorting, role_name';
end;

function TCrudConfigRole.GetSelectRecordSQL: string;
begin
  Result := 'select * from role where role_id = :Id';
end;

function TCrudConfigRole.GetTablename: string;
begin
  Result := 'role';
end;

function TCrudConfigRole.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigRole.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigRole.SetValues(const aRecord: TDtoRole; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('role_id', aRecord.Id);
  aAccessor.SetValue('role_name', aRecord.Name);
  aAccessor.SetValue('role_active', aRecord.Active);
  aAccessor.SetValue('role_sorting', aRecord.Sorting);
end;

procedure TCrudConfigRole.SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
begin

end;

procedure TCrudConfigRole.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoRole);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
