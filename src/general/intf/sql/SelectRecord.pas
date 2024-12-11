unit SelectRecord;

interface

uses SqlConnection;

type
  ISelectRecord<T> = interface
    ['{79A4B2B3-961B-4DAF-8181-BCCE701AD69C}']
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aRecord: T);
  end;

implementation

end.
