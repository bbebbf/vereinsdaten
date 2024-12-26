unit CrudConfigPersonAddress;

interface

uses InterfacedBase, CrudConfig, CrudAccessor, SqlConnection, DtoPersonAddress;

type
  TCrudConfigPersonAddress = class(TInterfacedBase, ICrudConfig<TDtoPersonAddress, UInt32>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoPersonAddress);
    function IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoPersonAddress; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: UInt32; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoPersonAddress);
    function GetRecordIdentity(const aRecord: TDtoPersonAddress): UInt32;
  end;

implementation

uses System.SysUtils;

{ TCrudConfigPersonAddress }

function TCrudConfigPersonAddress.GetIdentityColumns: TArray<string>;
begin
  Result := ['person_id'];
end;

function TCrudConfigPersonAddress.GetSelectRecordSQL: string;
begin
  Result := 'select * from person_address where person_id = :PersonId';
end;

function TCrudConfigPersonAddress.GetTablename: string;
begin
  Result := 'person_address';
end;

function TCrudConfigPersonAddress.IsNewRecord(const aRecordIdentity: UInt32): TCrudConfigNewRecordResponse;
begin
  Result := TCrudConfigNewRecordResponse.Unknown;
end;

procedure TCrudConfigPersonAddress.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: TDtoPersonAddress);
begin
  aRecord.PersonId := aSqlResult.FieldByName('person_id').AsLongWord;
  aRecord.AddressId := aSqlResult.FieldByName('adr_id').AsLongWord;
end;

function TCrudConfigPersonAddress.GetRecordIdentity(const aRecord: TDtoPersonAddress): UInt32;
begin
  Result := 0;
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

procedure TCrudConfigPersonAddress.SetSelectRecordSQLParameter(const aRecordIdentity: UInt32; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PersonId').Value := aRecordIdentity;
end;

procedure TCrudConfigPersonAddress.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert;
  var aRecord: TDtoPersonAddress);
begin
  raise ENotSupportedException.Create('TCrudConfigPersonAddress.UpdateRecordIdentity');
end;

end.
