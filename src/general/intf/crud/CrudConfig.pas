unit CrudConfig;

interface

uses CrudAccessor, SqlConnection, SelectRecord;

type
  TCrudConfigNewRecordResponse = (Unknown, NewRecord, ExistingRecord);

  ICrudConfig<TRecord; TRecordIdentity: record> = interface(ISelectRecord<TRecord>)
    ['{E9152F7A-7955-4227-8182-B34F85DC9A69}']
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectRecordSQL: string;
    procedure SetSelectRecordSQLParameter(const aRecordIdentity: TRecordIdentity; const aQuery: ISqlPreparedQuery);
    function IsNewRecord(const aRecord: TRecord): TCrudConfigNewRecordResponse;
    procedure SetValues(const aRecord: TRecord; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetValuesForDelete(const aRecordIdentity: TRecordIdentity; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TRecord);

    property Tablename: string read GetTablename;
  end;

implementation

end.
