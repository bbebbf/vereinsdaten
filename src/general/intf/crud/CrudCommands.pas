unit CrudCommands;

interface

type
  TCrudCommandResult = record
    Sucessful: Boolean;
  end;

  ICrudCommands<T> = interface
    ['{FB07E098-86FA-4B9F-8C65-04384425558B}']
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aRecordIdentity: T): TCrudCommandResult;
    function SaveCurrentRecord(const aRecordIdentity: T): TCrudCommandResult;
    function ReloadCurrentRecord(const aRecordIdentity: T): TCrudCommandResult;
    function DeleteRecord(const aRecordIdentity: T): TCrudCommandResult;
  end;

implementation

end.
