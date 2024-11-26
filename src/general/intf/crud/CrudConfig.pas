unit CrudConfig;

interface

uses CrudAccessor, SqlConnection;

type
  TCrudConfigNewRecordResponse = (Unknown, NewRecord, ExistingRecord);

  ICrudConfig<TRecord; TRecordIdentity: record> = interface
    ['{E9152F7A-7955-4227-8182-B34F85DC9A69}']
    function GetTablename: string;
    function GetIdentityColumns: TArray<string>;
    function GetSelectSqlList: string;
    function GetSelectSqlRecord: string;
    function IsNewRecord(const aRecord: TRecord): TCrudConfigNewRecordResponse;
    procedure SetRecordFromResult(const aSqlResult: ISqlResult; out aRecord: TRecord);
    procedure SetValues(const aRecord: TRecord; const aAccessor: TCrudAccessorBase; const aForUpdate: Boolean);
    procedure SetParametersForLoad(const aRecordIdentity: TRecordIdentity; const aQuery: ISqlPreparedQuery);
    procedure SetValuesForDelete(const aRecordIdentity: TRecordIdentity; const aAccessor: TCrudAccessorDelete);
    procedure UpdateRecordIdentity(const aAccessor: TCrudAccessorInsert; var aRecord: TRecord);

    property Tablename: string read GetTablename;
  end;

implementation

end.
