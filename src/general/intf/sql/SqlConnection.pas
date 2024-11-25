unit SqlConnection;

{$I \inc\CompilerDirectives.inc }

interface

uses Data.DB, Transaction;

type
  ISqlResult = interface
    ['{FB4B44B9-6188-4F3A-A542-70453B7A1286}']
    function Next: Boolean;
    function GetFieldCount: Integer;
    function FieldByName(const aName: string): TField;
    function FieldByIndex(const aIndex: Integer): TField;
    function FieldDefByIndex(const aIndex: Integer): TFieldDef;
    property Fields[const aIndex: Integer]: TField read FieldByIndex;
    property FieldDefs[const aIndex: Integer]: TFieldDef read FieldDefByIndex;
    property FieldCount: Integer read GetFieldCount;
  end;

  TSqlConnectionParametersBase = class abstract
  strict private
    fHost: string;
    fPort: Integer;
    fDatabasename: string;
    fUsername: string;
    fPassword: string;
  public
    function GetConnectionString: string; virtual; abstract;
    property Host: string read fHost write fHost;
    property Port: Integer read fPort write fPort;
    property Databasename: string read fDatabasename write fDatabasename;
    property Username: string read fUsername write fUsername;
    property Password: string read fPassword write fPassword;
  end;

  ISqlParameter = interface
    ['{B517592F-9661-47B0-8396-5148BA02B035}']
    function GetName: string;
    function GetDataType: TFieldType;
    procedure SetDataType(const aValue: TFieldType);
    function GetValue: Variant;
    procedure SetValue(const aValue: Variant);
    property Name: string read GetName;
    property DataType: TFieldType read GetDataType write SetDataType;
    property Value: Variant read GetValue write SetValue;
  end;

  ISqlPreparedBase = interface
    ['{9BF3F53C-E0BE-4F0A-B47A-C39E2AA9AC1B}']
    procedure Prepare;
    function GetParamCount: Integer;
    function ParamByName(const aName: string): ISqlParameter;
    function ParamByIndex(const aIndex: Integer): ISqlParameter;
    property Params[const aIndex: Integer]: ISqlParameter read ParamByIndex;
    property ParamCount: Integer read GetParamCount;
  end;

  ISqlPreparedCommand = interface(ISqlPreparedBase)
    ['{2086F60E-B0CB-475D-9D3F-572BCF390D9B}']
    function Execute: Integer;
  end;

  ISqlPreparedQuery = interface(ISqlPreparedBase)
    ['{2086F60E-B0CB-475D-9D3F-572BCF390D9B}']
    function Open: ISqlResult;
  end;

  ISqlConnection = interface
    ['{E51D5D5C-F68E-4E14-8A8E-2CB890AF71E8}']
    function GetParameters: TSqlConnectionParametersBase;
    function Connect: Boolean;
    function CreatePreparedCommand(const aSqlCommand: string; const aTransaction: ITransaction = nil): ISqlPreparedCommand;
    function CreatePreparedQuery(const aSqlCommand: string; const aTransaction: ITransaction = nil): ISqlPreparedQuery;
    function GetSelectResult(const aSqlSelect: string;
      const aTransaction: ITransaction = nil): ISqlResult;
    function ExecuteCommand(const aSqlCommand: string;
      const aTransaction: ITransaction = nil): Integer;
    function StartTransaction: ITransaction;
    function GetLastInsertedIdentityScoped: Int64;
    property Parameters: TSqlConnectionParametersBase read GetParameters;
  end;

implementation

end.
