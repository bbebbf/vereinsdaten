unit CrudConfigClubmembership;

interface

uses System.SysUtils, CrudConfig, CrudAccessor, SqlConnection, DtoClubmembership;

type
  TCrudConfigClubmembership = class(TInterfacedObject, ICrudConfig<TDtoClubmembership, Int32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectSqlList: string;
    function GetSelectSqlRecord: string;
    procedure SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoClubmembership);
    function IsNewRecord(const aRecord: TDtoClubmembership): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoClubmembership; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetParametersForLoad(const aRecordIdentity: Int32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: Int32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoClubmembership);
  end;


implementation

{ TCrudConfigClubmembership }

function TCrudConfigClubmembership.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

function TCrudConfigClubmembership.GetSelectSqlList: string;
begin
  raise ENotSupportedException.Create('TCrudConfigClubmembership.GetSelectSqlList');
end;

function TCrudConfigClubmembership.GetSelectSqlRecord: string;
begin
  Result := 'select * from clubmembership where person_id = :PersonId';
end;

function TCrudConfigClubmembership.GetTablename: string;
begin
  Result := 'clubmembership';
end;

function TCrudConfigClubmembership.IsNewRecord(const aRecord: TDtoClubmembership): TCrudConfigNewRecordResponse;
begin
  if aRecord.Id = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigClubmembership.SetParametersForLoad(const aRecordIdentity: Int32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PersonId').Value := aRecordIdentity;
end;

procedure TCrudConfigClubmembership.SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoClubmembership);
begin
  aRecord.Id := aSqlResult.FieldByName('clmb_id').AsInteger;
  aRecord.PersonId := aSqlResult.FieldByName('person_id').AsInteger;
  aRecord.Number := aSqlResult.FieldByName('clmb_number').AsInteger;
  aRecord.Active := aSqlResult.FieldByName('clmb_active').AsBoolean;
  aRecord.Startdate := aSqlResult.FieldByName('clmb_startdate').AsDateTime;
  aRecord.Enddate := aSqlResult.FieldByName('clmb_enddate').AsDateTime;
  aRecord.EnddateStr := aSqlResult.FieldByName('clmb_enddate_str').AsString;
  aRecord.Endreason := aSqlResult.FieldByName('clmb_endreason').AsString;
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

procedure TCrudConfigClubmembership.SetValuesForDelete(const aRecordIdentity: Int32;
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
