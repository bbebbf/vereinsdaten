unit CrudConfigPersonAddress;

interface

uses System.SysUtils, CrudConfig, CrudAccessor, SqlConnection, DtoPersonAddress;

type
  TCrudConfigPersonAddress = class(TInterfacedObject, ICrudConfig<TDtoPersonAddress, UInt32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectSqlList: string;
    function GetSelectSqlRecord: string;
    procedure SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoPersonAddress);
    function IsNewRecord(const aRecord: TDtoPersonAddress): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoPersonAddress; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetParametersForLoad(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoPersonAddress);
  end;

implementation

{ TCrudConfigPersonAddress }

function TCrudConfigPersonAddress.GetIdentityColumns: TArray<string>;
begin
  Result := ['person_id'];
end;

function TCrudConfigPersonAddress.GetSelectSqlList: string;
begin
  raise ENotSupportedException.Create('TCrudConfigPersonAddress.GetSelectSqlList');
end;

function TCrudConfigPersonAddress.GetSelectSqlRecord: string;
begin
  Result := 'select * from person_address where person_id = :PersonId';
end;

function TCrudConfigPersonAddress.GetTablename: string;
begin
  Result := 'person_address';
end;

function TCrudConfigPersonAddress.IsNewRecord(const aRecord: TDtoPersonAddress): TCrudConfigNewRecordResponse;
begin
  Result := TCrudConfigNewRecordResponse.Unknown;
end;

procedure TCrudConfigPersonAddress.SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TDtoPersonAddress);
begin
  aRecord.PersonId := aSqlResult.FieldByName('person_id').AsLongWord;
  aRecord.AddressId := aSqlResult.FieldByName('adr_id').AsLongWord;
end;

procedure TCrudConfigPersonAddress.SetValues(const aRecord: TDtoPersonAddress; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  aAccessor.SetValue('person_id', aRecord.PersonId);
  aAccessor.SetValue('adr_id', aRecord.AddressId);
end;

procedure TCrudConfigPersonAddress.SetValuesForDelete(const aRecordIdentity: UInt32;
  const aAccessor: TCrudAccessorDelete);
begin
  aAccessor.SetValue('person_id', aRecordIdentity);
end;

procedure TCrudConfigPersonAddress.SetParametersForLoad(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PersonId').Value := aRecordIdentity;
end;

procedure TCrudConfigPersonAddress.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert;
  var aRecord: TDtoPersonAddress);
begin

end;

end.
