unit CrudBusiness;

interface

uses System.SysUtils, SqlConnection, CrudCommands, CrudUI, EntryCrudConfig;

type
  TCrudBusiness<TEntry: class; TId: record> = class(TInterfacedObject, ICrudCommands<TId>)
  strict private
    fUI: ICrudUI<TEntry, TId>;
    fConfig: IEntryCrudConfig<TEntry, TId>;
    fNewEntryStarted: Boolean;
    fCurrentEntry: TEntry;
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aId: TId): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    procedure StartNewEntry;
    function DeleteEntry(const aId: TId): TCrudCommandResult;
  public
    constructor Create(const aUI: ICrudUI<TEntry, TId>; const aConfig: IEntryCrudConfig<TEntry, TId>);
  end;

implementation

{ TCrudBusiness<TEntry, TId> }

constructor TCrudBusiness<TEntry, TId>.Create(const aUI: ICrudUI<TEntry, TId>;
  const aConfig: IEntryCrudConfig<TEntry, TId>);
begin
  inherited Create;
  fUI := aUI;
  fConfig := aConfig;
end;

procedure TCrudBusiness<TEntry, TId>.Initialize;
begin
  var lCrudCommands: ICrudCommands<TId>;
  if not Supports(Self, ICrudCommands<TId>, lCrudCommands) then
    raise ENotImplemented.Create('ICrudCommands<TId> is not implemented.');

  fUI.Initialize(lCrudCommands)
end;

function TCrudBusiness<TEntry, TId>.LoadList: TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fNewEntryStarted := False;
  fUI.ClearEntryFromUI;
  fUI.ListEnumBegin;
  try
    var lSqlResult := fConfig.GetListSqlResult;
    while lSqlResult.Next do
    begin
      var lEntry := fConfig.GetEntryFromListSqlResult(lSqlResult);
      if fConfig.IsEntryValidForList(lEntry) then
        fUI.ListEnumProcessItem(lEntry)
      else
        fConfig.DestroyEntry(lEntry);
    end;
  finally
    fUI.ListEnumEnd;
  end;
end;

function TCrudBusiness<TEntry, TId>.LoadCurrentEntry(const aId: TId): TCrudCommandResult;
begin
  fConfig.DestroyEntry(fCurrentEntry);
  fNewEntryStarted := False;
  if fConfig.TryLoadEntry(aId, fCurrentEntry) then
  begin
    fUI.SetEntryToUI(fCurrentEntry, False);
  end
  else
  begin
    fUI.ClearEntryFromUI;
    fUI.DeleteEntryFromUI(aId);
  end;
end;

function TCrudBusiness<TEntry, TId>.SaveCurrentEntry: TCrudSaveResult;
begin
  var lDestroyTempSavingEntry := True;
  var lTempSavingEntry: TEntry;
  try
    if fNewEntryStarted or fConfig.IsEntryUndefined(fCurrentEntry) then
    begin
      lTempSavingEntry := fConfig.CreateEntry;
    end
    else
    begin
      lTempSavingEntry := fConfig.CloneEntry(fCurrentEntry);
    end;

    if not fUI.GetEntryFromUI(lTempSavingEntry) then
    begin
      Exit(TCrudSaveResult.CreateRecord(TCrudSaveStatus.Cancelled));
    end;
    if not fConfig.IsEntryValidForSaving(lTempSavingEntry) then
    begin
      Exit(TCrudSaveResult.CreateRecord(TCrudSaveStatus.Cancelled));
    end;

    if fConfig.SaveEntry(lTempSavingEntry) then
    begin
      fConfig.DestroyEntry(fCurrentEntry);
      fCurrentEntry := lTempSavingEntry;
      lDestroyTempSavingEntry := False;
      fUI.SetEntryToUI(fCurrentEntry, fNewEntryStarted);
      fNewEntryStarted := False;
    end;
  finally
    if lDestroyTempSavingEntry then
      fConfig.DestroyEntry(lTempSavingEntry);
  end;
end;

procedure TCrudBusiness<TEntry, TId>.StartNewEntry;
begin
  fNewEntryStarted := True;
  fUI.ClearEntryFromUI;
end;

function TCrudBusiness<TEntry, TId>.ReloadCurrentEntry: TCrudCommandResult;
begin
  fUI.SetEntryToUI(fCurrentEntry, False);
end;

function TCrudBusiness<TEntry, TId>.DeleteEntry(const aId: TId): TCrudCommandResult;
begin

end;

end.
