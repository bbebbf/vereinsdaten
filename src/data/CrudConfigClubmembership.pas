unit CrudConfigClubmembership;

interface

uses System.SysUtils, CrudConfig, CrudAccessor, SqlConnection, DtoClubmembership;

type
  TCrudConfigClubmembership = class(TInterfacedObject, ICrudConfig<TDtoClubmembership, UInt32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoClubmembership);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoClubmembership; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoClubmembership);
    function GetRecordIdentity(const aRecord: TDtoClubmembership): UInt32;
  end;


implementation

{ TCrudConfigClubmembership }

function TCrudConfigClubmembership.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

function TCrudConfigClubmembership.GetSelectRecordSQL: string;
begin
  Result := 'select * from clubmembership where person_id = :PersonId';
end;

function TCrudConfigClubmembership.GetTablename: string;
begin
  Result := 'clubmembership';
end;

function TCrudConfigClubmembership.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigClubmembership.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PersonId').Value := aRecordIdentity;
end;

procedure TCrudConfigClubmembership.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoClubmembership);
begin
  aRecord.Id := aSqlResult.FieldByName('clmb_id').AsLongWord;
  aRecord.PersonId := aSqlResult.FieldByName('person_id').AsLongWord;
  aRecord.Number := aSqlResult.FieldByName('clmb_number').AsLongWord;
  aRecord.Active := aSqlResult.FieldByName('clmb_active').AsBoolean;
  aRecord.Startdate := aSqlResult.FieldByName('clmb_startdate').AsDateTime;
  aRecord.Enddate := aSqlResult.FieldByName('clmb_enddate').AsDateTime;
  aRecord.EnddateStr := aSqlResult.FieldByName('clmb_enddate_str').AsString;
  aRecord.Endreason := aSqlResult.FieldByName('clmb_endreason').AsString;
end;

function TCrudConfigClubmembership.GetRecordIdentity(const aRecord: TDtoClubmembership): UInt32;
begin
  Result := aRecord.Id;
end;

procedure TCrudConfigClubmembership.SetValues(const aRecord: TDtoClubmembership; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('clmb_id', aRecord.Id);
  aAccessor.SetValue('person_id', aRecord.PersonId);
  aAccessor.SetValueZeroAsNull('clmb_number', aRecord.Number);
  aAccessor.SetValue('clmb_active', aRecord.Active);
  aAccessor.SetValueZeroAsNull('clmb_startdate', aRecord.Startdate);
  aAccessor.SetValueZeroAsNull('clmb_enddate', aRecord.Enddate);
  aAccessor.SetValueEmptyStrAsNull('clmb_enddate_str', aRecord.EnddateStr);
  aAccessor.SetValueEmptyStrAsNull('clmb_endreason', aRecord.Endreason);
end;

procedure TCrudConfigClubmembership.SetValuesForDelete(const aRecordIdentity: UInt32;
  const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('clmb_id', aRecordIdentity);
end;

procedure TCrudConfigClubmembership.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert;
  var aRecord: TDtoClubmembership);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
