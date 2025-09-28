unit Exporter.Types;

interface

uses SqlConnection;

type
  IExporterTargetConfig = interface
    ['{31DF37FF-7EA5-4106-BC90-0378FC20AA2A}']
    function GetTitle: string;
    function GetResultMessageRequired: Boolean;
    property Title: string read GetTitle;
    property ResultMessageRequired: Boolean read GetResultMessageRequired;
  end;

  TExporterExportResult = record
    Sucessful: Boolean;
    FilePath: string;
  end;

  IExporterTarget<T> = interface(IExporterTargetConfig)
    ['{1712A820-7D88-49F4-8FD0-27E33A0B34CD}']
    procedure SetParams(const aParams: T);
    function ExportDataSet(const aDataSet: ISqlDataSet): TExporterExportResult;
  end;

  IExporterTargetProvider = interface
    ['{C83EF339-7111-4289-8EE8-CA4175C318DC}']
    procedure SetTargets(const aTargets: TArray<IExporterTargetConfig>);
    function GetTargetIndex: Integer;
  end;

  IExporterRequiresFilePath = interface
    ['{78F791A8-8259-4241-A9C1-F16E44373F7B}']
    function GetSuggestedFileName: string;
    function GetFilePath: string;
    procedure SetFilePath(const aValue: string);
    procedure Assign(const aExporterRequiresFilePath: IExporterRequiresFilePath);
    property SuggestedFileName: string read GetSuggestedFileName;
    property FilePath: string read GetFilePath write SetFilePath;
  end;

  IExporterResultMessageNotifier = interface
    ['{24029429-5CD8-4C13-82F4-6C6CA723D377}']
    procedure ResultMessage(const aExporterExportResult: TExporterExportResult);
  end;


implementation

end.

