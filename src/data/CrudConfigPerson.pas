unit CrudConfigPerson;

interface

uses InterfacedBase, CrudConfig, SelectList, CrudAccessor, SqlConnection, DtoPerson, Vdm.Types;

type
  TCrudConfigPerson = class(TInterfacedBase, ICrudConfig<TDtoPerson, UInt32>, ISelectList<TDtoPerson>, ISelectListActiveEntries<TDtoPerson>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoPerson);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoPerson; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoPerson);
    function GetSelectListSQL: string;
    function GetSelectListActiveEntriesSQL: string;
    function GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
  end;

implementation

{ TCrudConfigPerson }

procedure TCrudConfigPerson.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoPerson);
begin
  aRecord.NameId.Id := aSqlResult.FieldByName('person_id').AsLongWord;
  aRecord.NameId.Firstname := aSqlResult.FieldByName('person_firstname').AsString;
  aRecord.NameId.NameAddition := aSqlResult.FieldByName('person_nameaddition').AsString;
  aRecord.NameId.Lastname := aSqlResult.FieldByName('person_lastname').AsString;
  aRecord.Active := aSqlResult.FieldByName('person_active').AsBoolean;
  aRecord.Birthday := aSqlResult.FieldByName('person_birthday').AsDateTime;
end;

function TCrudConfigPerson.GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
begin
  Result := aRecord.NameId.Id;
end;

function TCrudConfigPerson.GetIdentityColumns: TArray<string>;
begin
  Result := [];
end;

function TCrudConfigPerson.GetSelectListActiveEntriesSQL: string;
begin
  Result := 'select * from person where person_active = 1 order by person_lastname, person_firstname, person_nameaddition';
end;

function TCrudConfigPerson.GetSelectListSQL: string;
begin
  Result := 'select * from person order by person_lastname, person_firstname, person_nameaddition';
end;

function TCrudConfigPerson.GetSelectRecordSQL: string;
begin
  Result := 'select * from person where person_id = :Id';
end;

function TCrudConfigPerson.GetTablename: string;
begin
  Result := 'person';
end;

function TCrudConfigPerson.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  if aRecordIdentity = 0 then
    Result := TCrudConfigNewRecordResponse.NewRecord
  else
    Result := TCrudConfigNewRecordResponse.ExistingRecord;
end;

procedure TCrudConfigPerson.SetValues(const aRecord: TDtoPerson; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  if aForUpdate then
    aAccessor.SetValue('person_id', aRecord.NameId.Id);
  aAccessor.SetValueEmptyStrAsNull('person_firstname', aRecord.NameId.Firstname);
  aAccessor.SetValueEmptyStrAsNull('person_nameaddition', aRecord.NameId.NameAddition);
  aAccessor.SetValueEmptyStrAsNull('person_lastname', aRecord.NameId.Lastname);
  aAccessor.SetValue('person_active', aRecord.Active);
  aAccessor.SetValueZeroAsNull('person_birthday', aRecord.Birthday)
end;

procedure TCrudConfigPerson.SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('person_id', aRecordIdentity);
end;

procedure TCrudConfigPerson.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigPerson.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoPerson);
begin
  aRecord.NameId.Id := aAccessor.LastInsertedId;
end;

end.
