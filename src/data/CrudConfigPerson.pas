unit CrudConfigPerson;

interface

uses InterfacedBase, CrudConfig, SelectList, CrudAccessor, SqlConnection, DtoPerson, Vdm.Types, ListFilterPerson;

type
  TCrudConfigPerson = class(TInterfacedBase, ICrudConfig<TDtoPerson, UInt32>, ISelectList<TDtoPerson>,
    IParameterizedSelectList<TListFilterPerson>)
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
    function GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
    function GetParameterizedSelectQuery(const aConnection: ISqlConnection;
      const aListParams: TListFilterPerson): ISqlPreparedQuery;
  end;

implementation

uses SimpleDate;

{ TCrudConfigPerson }

procedure TCrudConfigPerson.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoPerson);
begin
  aRecord.NameId.Id := aSqlResult.FieldByName('person_id').AsLongWord;
  aRecord.NameId.Firstname := aSqlResult.FieldByName('person_firstname').AsString;
  aRecord.NameId.NameAddition := aSqlResult.FieldByName('person_nameaddition').AsString;
  aRecord.NameId.Lastname := aSqlResult.FieldByName('person_lastname').AsString;
  aRecord.Active := aSqlResult.FieldByName('person_active').AsBoolean;
  aRecord.External := aSqlResult.FieldByName('person_external').AsBoolean;

  var lBirthdayField := aSqlResult.FieldByName('person_date_of_birth');
  if lBirthdayField.IsNull then
  begin
    var lBirthdayDayField := aSqlResult.FieldByName('person_day_of_birth');
    var lBirthdayMonthField := aSqlResult.FieldByName('person_month_of_birth');
    if lBirthdayDayField.IsNull or lBirthdayMonthField.IsNull then
    begin
      aRecord.Birthday.Reset;
    end
    else
    begin
      var lSimpleDate := default(TSimpleDate);
      lSimpleDate.Day := lBirthdayDayField.AsLongWord;
      lSimpleDate.Month := lBirthdayMonthField.AsLongWord;
      aRecord.Birthday.Value := lSimpleDate;
    end;
  end
  else
  begin
    aRecord.Birthday.Value := lBirthdayField.AsDateTime;
  end;

  aRecord.OnBirthdayList := aSqlResult.FieldByName('person_on_birthday_list').AsBoolean;
  aRecord.Emailaddress := aSqlResult.FieldByName('person_email').AsString;
  aRecord.Phonenumber := aSqlResult.FieldByName('person_phone').AsString;
  aRecord.PhonePriority := aSqlResult.FieldByName('person_phone_priority').AsBoolean;
end;

function TCrudConfigPerson.GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
begin
  Result := aRecord.NameId.Id;
end;

function TCrudConfigPerson.GetIdentityColumns: TArray<string>;
begin
  Result := [];
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
  aAccessor.SetValue('person_external', aRecord.External);
  if aRecord.Birthday.HasValue then
  begin
    aAccessor.SetValueZeroAsNull('person_day_of_birth', aRecord.Birthday.Value.Day);
    aAccessor.SetValueZeroAsNull('person_month_of_birth', aRecord.Birthday.Value.Month);
    if aRecord.Birthday.Value.IsYearKnown then
    begin
      aAccessor.SetValue('person_date_of_birth', aRecord.Birthday.Value.AsDate);
    end
    else
    begin
      aAccessor.SetValueToNull('person_date_of_birth');
    end;
  end
  else
  begin
    aAccessor.SetValueToNull('person_date_of_birth');
    aAccessor.SetValueToNull('person_day_of_birth');
    aAccessor.SetValueToNull('person_month_of_birth');
  end;
  aAccessor.SetValue('person_on_birthday_list', aRecord.OnBirthdayList);
  aAccessor.SetValueEmptyStrAsNull('person_email', aRecord.Emailaddress);
  aAccessor.SetValueEmptyStrAsNull('person_phone', aRecord.Phonenumber);
  aAccessor.SetValue('person_phone_priority', aRecord.PhonePriority);
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

function TCrudConfigPerson.GetParameterizedSelectQuery(const aConnection: ISqlConnection;
  const aListParams: TListFilterPerson): ISqlPreparedQuery;
begin
  Result := aConnection.CreatePreparedQuery(
    'select * from person' +
    ' where (person_active = 1 or :only_active = 0)' +
    ' and (person_external = 0 or :include_external = 1)' +
    ' order by person_lastname, person_firstname, person_nameaddition'
    );
  if aListParams.IncludeInactive then
  begin
    Result.ParamByName('only_active').Value := 0;
  end
  else
  begin
    Result.ParamByName('only_active').Value := 1;
  end;
  if aListParams.IncludeExternal then
  begin
    Result.ParamByName('include_external').Value := 1;
  end
  else
  begin
    Result.ParamByName('include_external').Value := 0;
  end;
end;

end.
