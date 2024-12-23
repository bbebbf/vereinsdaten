unit CrudCommands;

interface

type
  TCrudCommandResult = record
    Sucessful: Boolean;
  end;

  TCrudSaveRecordStatus = (Successful, Cancelled, CancelledWithMessage, Failed);
  TCrudSaveRecordResult = record
    Status: TCrudSaveRecordStatus;
    MessageText: string;
    class function CreateRecord(const aStatus: TCrudSaveRecordStatus): TCrudSaveRecordResult; static;
    class function CreateCancelledRecord(const aMessageText: string): TCrudSaveRecordResult; static;
    class function CreateFailedRecord(const aMessageText: string = ''): TCrudSaveRecordResult; static;
  end;

  ICrudCommands<T: record> = interface
    ['{FB07E098-86FA-4B9F-8C65-04384425558B}']
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aRecordIdentity: T): TCrudCommandResult;
    function SaveCurrentRecord(const aRecordIdentity: T): TCrudSaveRecordResult;
    function ReloadCurrentRecord(const aRecordIdentity: T): TCrudCommandResult;
    function DeleteRecord(const aRecordIdentity: T): TCrudCommandResult;
  end;

implementation

{ TCrudSaveRecordResult }

class function TCrudSaveRecordResult.CreateCancelledRecord(const aMessageText: string): TCrudSaveRecordResult;
begin
  Result := default(TCrudSaveRecordResult);
  Result.Status := TCrudSaveRecordStatus.CancelledWithMessage;
  Result.MessageText := aMessageText;
end;

class function TCrudSaveRecordResult.CreateFailedRecord(const aMessageText: string): TCrudSaveRecordResult;
begin
  Result := default(TCrudSaveRecordResult);
  Result.Status := TCrudSaveRecordStatus.Failed;
  Result.MessageText := aMessageText;
end;

class function TCrudSaveRecordResult.CreateRecord(const aStatus: TCrudSaveRecordStatus): TCrudSaveRecordResult;
begin
  Result := default(TCrudSaveRecordResult);
  Result.Status := aStatus;
end;

end.
