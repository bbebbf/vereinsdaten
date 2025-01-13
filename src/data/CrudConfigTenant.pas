unit CrudConfigTenant;

interface

uses InterfacedBase, SelectList, SqlConnection, CrudConfig, CrudAccessor, DtoTenant;

type
  TCrudConfigTenant = class(TInterfacedBase, ICrudConfig<TDtoTenant, UInt8>, ISelectList<TDtoTenant>)
  strict private
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: UInt8; const aQuery: ISqlPreparedQuery);
    function IsNewRecord(const aRecordIdentity: UInt8): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TDtoTenant; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetValuesForDelete(const aRecordIdentity: UInt8; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoTenant);
    function GetRecordIdentity(const aRecord: TDtoTenant): UInt8;

    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoTenant);
    function GetSelectListSQL: string;
  end;

implementation

{ TCrudConfigTenant }

function TCrudConfigTenant.GetIdentityColumns: TArray<string>;
begin
  Result := ['ten_id'];
end;

procedure TCrudConfigTenant.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoTenant);
begin
  aData.Id := aSqlResult.FieldByName('ten_id').AsLargeInt;
  aData.Title := aSqlResult.FieldByName('ten_title').AsString;
end;

function TCrudConfigTenant.GetRecordIdentity(const aRecord: TDtoTenant): UInt8;
begin
  Result := aRecord.Id;
end;

function TCrudConfigTenant.GetSelectListSQL: string;
begin
  Result := 'select * from tenant order by ten_id';
end;

function TCrudConfigTenant.GetSelectRecordSQL: string;
begin
  Result := 'select * from tenant where ten_id = :Id';
end;

function TCrudConfigTenant.GetTablename: string;
begin
  Result := 'tenant';
end;

function TCrudConfigTenant.IsNewRecord(const aRecordIdentity: UInt8): TCrudConfigNewRecordResponse;
begin
  Result := TCrudConfigNewRecordResponse.Unknown;
end;

procedure TCrudConfigTenant.SetSelectRecordSQLParameter(const aRecordIdentity: UInt8; const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('Id').Value := aRecordIdentity;
end;

procedure TCrudConfigTenant.SetValues(const aRecord: TDtoTenant; const aAccessor: TCrudAccessorBase;
  const aForUpdate: Boolean);
begin
  aAccessor.SetValue('ten_id', aRecord.Id);
  aAccessor.SetValue('ten_title', aRecord.Title);
end;

procedure TCrudConfigTenant.SetValuesForDelete(const aRecordIdentity: UInt8; const aAccessor: TCrudAccessorDelete);
begin

end;

procedure TCrudConfigTenant.UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TDtoTenant);
begin
  aRecord.Id := aAccessor.LastInsertedId;
end;

end.
