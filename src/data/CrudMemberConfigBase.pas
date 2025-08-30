unit CrudMemberConfigBase;

interface

uses InterfacedBase, SqlConnection, CrudAccessor, CrudConfig, SelectListFilter, DtoMember, KeyIndexStrings,
  MemberOfConfigIntf, Vdm.Versioning.Types;

type
  TCrudMemberConfigBase = class abstract(TInterfacedBase,
    IMemberOfConfigIntf,
    ISelectListFilter<TDtoMember, UInt32>,
    ISelectVersionInfo)
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
    function GetRecordIdentity(const aRecord: TDtoMember): UInt32;
  strict protected
    function GetSelectListSQL: string; virtual; abstract;
    procedure SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery); virtual; abstract;
    function GetDetailItemTitle: string; virtual; abstract;
    function GetDetailItemMapper: TActiveKeyIndexStringsLoader; virtual; abstract;
    function GetShowVersionInfoInMemberListview: Boolean; virtual;
    procedure SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember); virtual; abstract;
    function GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32; virtual; abstract;
    procedure SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember); virtual; abstract;
    function GetEntryVersionInfoFromResult(const aSqlResult: ISqlResult; out aEntry: TEntryVersionInfo): Boolean; virtual;
  end;

implementation

uses Vdm.Globals;

{ TCrudMemberConfigBase }

function TCrudMemberConfigBase.GetEntryVersionInfoFromResult(const aSqlResult: ISqlResult;
  out aEntry: TEntryVersionInfo): Boolean;
begin
  Result := False;
end;

function TCrudMemberConfigBase.GetIdentityColumns: TArray<string>;
begin

end;

procedure TCrudMemberConfigBase.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoMember);
begin
  aData.Id := aSqlResult.FieldByName('mb_id').AsLargeInt;
  aData.PersonId := aSqlResult.FieldByName('person_id').AsLargeInt;
  aData.UnitId := aSqlResult.FieldByName('unit_id').AsLargeInt;
  aData.RoleId := aSqlResult.FieldByName('role_id').AsLargeInt;
  aData.Active := aSqlResult.FieldByName('mb_active').AsBoolean;
  aData.ActiveSince.Value := aSqlResult.FieldByName('mb_active_since').AsDateTime;
  aData.ActiveUntil.Value := aSqlResult.FieldByName('mb_active_until').AsDateTime;
end;

function TCrudMemberConfigBase.GetRecordIdentity(const aRecord: TDtoMember): UInt32;
begin
  Result := aRecord.Id;
end;

function TCrudMemberConfigBase.GetSelectRecordSQL: string;
begin
  Result := 'select * from member where mb_id = :MId';
end;

function TCrudMemberConfigBase.GetShowVersionInfoInMemberListview: Boolean;
begin
  Result := False;
end;

function TCrudMemberConfigBase.GetTablename: string;
begin
  Result := 'member';
end;

function TCrudMemberConfigBase.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudMemberConfigBase.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('MId').Value := aRecordIdentity;
end;

procedure TCrudMemberConfigBase.SetValues(const aRecord: TDtoMember; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('mb_id', aRecord.Id);
  aAccessor.SetValueZeroAsNull('person_id', aRecord.PersonId);
  aAccessor.SetValueZeroAsNull('unit_id', aRecord.UnitId);
  aAccessor.SetValueZeroAsNull('role_id', aRecord.RoleId);
  aAccessor.SetValue('mb_active', aRecord.Active);
  aAccessor.SetValueZeroAsNull('mb_active_since', aRecord.ActiveSince.Value);
  aAccessor.SetValueZeroAsNull('mb_active_until', aRecord.ActiveUntil.Value);
end;

procedure TCrudMemberConfigBase.SetValuesForDelete(const aRecordIdentity: UInt32;
  const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('mb_id', aRecordIdentity);
end;

procedure TCrudMemberConfigBase.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoMember);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
