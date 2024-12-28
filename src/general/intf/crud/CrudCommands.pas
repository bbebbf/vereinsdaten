unit CrudCommands;

interface

type
  TCrudCommandResult = record
    Sucessful: Boolean;
  end;

  TCrudSaveStatus = (Successful, Cancelled, CancelledWithMessage, Failed);
  TCrudSaveResult = record
    Status: TCrudSaveStatus;
    MessageText: string;
    class function CreateRecord(const aStatus: TCrudSaveStatus): TCrudSaveResult; static;
    class function CreateCancelledRecord(const aMessageText: string): TCrudSaveResult; static;
    class function CreateFailedRecord(const aMessageText: string = ''): TCrudSaveResult; static;
  end;

  ICrudCommands<T, F: record> = interface
    ['{FB07E098-86FA-4B9F-8C65-04384425558B}']
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aEntryId: T): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    function DeleteEntry(const aEntryId: T): TCrudCommandResult;
    procedure StartNewEntry;
    function GetDataChanged: Boolean;
    function GetListFilter: F;
    procedure SetListFilter(const aValue: F);
    property DataChanged: Boolean read GetDataChanged;
    property ListFilter: F read GetListFilter write SetListFilter;
  end;

implementation

{ TCrudSaveResult }

class function TCrudSaveResult.CreateCancelledRecord(const aMessageText: string): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  Result.Status := TCrudSaveStatus.CancelledWithMessage;
  Result.MessageText := aMessageText;
end;

class function TCrudSaveResult.CreateFailedRecord(const aMessageText: string): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  Result.Status := TCrudSaveStatus.Failed;
  Result.MessageText := aMessageText;
end;

class function TCrudSaveResult.CreateRecord(const aStatus: TCrudSaveStatus): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  Result.Status := aStatus;
end;

end.
