unit Exporter.Types;

interface

uses SqlConnection;

type
  IExporterTarget<T> = interface
    ['{1712A820-7D88-49F4-8FD0-27E33A0B34CD}']
    function GetTitle: string;
    procedure SetParams(const aParams: T);
    procedure DoExport(const aDataSet: ISqlDataSet);
    property Title: string read GetTitle;
  end;

implementation

end.
