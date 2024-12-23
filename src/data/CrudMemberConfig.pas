unit CrudMemberConfig;

interface

uses System.SysUtils, SqlConnection, CrudAccessor, CrudConfig, SelectListFilter, DtoMember;

type
  TCrudMemberConfig = class(TInterfacedObject,
    ICrudConfig<TDtoMember, UInt32>,
    ISelectListFilter<TDtoMember, UInt32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoMember; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoMember);
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoMember);
    function GetSelectListSQL: string;
    procedure SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery);
    function GetRecordIdentity(const aRecord: TDtoMember): UInt32;
  end;

implementation

{ TCrudMemberConfig }

function TCrudMemberConfig.GetIdentityColumns: TArray<string>;
begin

end;

procedure TCrudMemberConfig.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoMember);
begin
  aData.Id := aSqlResult.FieldByName('mb_id').AsLargeInt;
  aData.PersonId := aSqlResult.FieldByName('person_id').AsLargeInt;
  aData.UnitId := aSqlResult.FieldByName('unit_id').AsLargeInt;
  aData.RoleId := aSqlResult.FieldByName('role_id').AsLargeInt;
  aData.Active := aSqlResult.FieldByName('mb_active').AsBoolean;
  aData.ActiveSince := aSqlResult.FieldByName('mb_active_since').AsDateTime;
  aData.ActiveUntil := aSqlResult.FieldByName('mb_active_until').AsDateTime;
end;

function TCrudMemberConfig.GetRecordIdentity(const aRecord: TDtoMember): UInt32;
begin
  Result := aRecord.Id;
end;

function TCrudMemberConfig.GetSelectListSQL: string;
begin
  Result := 'SELECT m.*'
    + ' FROM `member`AS m'
    + ' INNER JOIN `unit` AS u ON u.unit_id = m.unit_id'
    + ' LEFT JOIN `role` AS r ON r.role_id = m.role_id'
    + ' WHERE m.person_id = :PId'
    + ' ORDER BY IFNULL(r.role_sorting, 10000), u.unit_name, m.mb_active_since DESC';
end;

function TCrudMemberConfig.GetSelectRecordSQL: string;
begin
  Result := 'select * from member where mb_id = :MId';
end;

function TCrudMemberConfig.GetTablename: string;
begin
  Result := 'member';
end;

function TCrudMemberConfig.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudMemberConfig.SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PId').Value := aFilter;
end;

procedure TCrudMemberConfig.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('MId').Value := aRecordIdentity;
end;

procedure TCrudMemberConfig.SetValues(const aRecord: TDtoMember; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('mb_id', aRecord.Id);
  aAccessor.SetValueZeroAsNull('person_id', aRecord.PersonId);
  aAccessor.SetValueZeroAsNull('unit_id', aRecord.UnitId);
  aAccessor.SetValueZeroAsNull('role_id', aRecord.RoleId);
  aAccessor.SetValue('mb_active', aRecord.Active);
  aAccessor.SetValueZeroAsNull('mb_active_since', aRecord.ActiveSince);
  aAccessor.SetValueZeroAsNull('mb_active_until', aRecord.ActiveUntil);
end;

procedure TCrudMemberConfig.SetValuesForDelete(const aRecordIdentity: UInt32;
  const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('mb_id', aRecordIdentity);
end;

procedure TCrudMemberConfig.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoMember);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
