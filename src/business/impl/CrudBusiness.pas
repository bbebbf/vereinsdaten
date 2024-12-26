unit CrudBusiness;

interface

uses InterfacedBase, SqlConnection, CrudCommands, CrudUI, EntryCrudConfig;

type
  TCrudBusiness<TEntry; TListEntry; TId: record> = class(TInterfacedBase, ICrudCommands<TId>)
  strict private
    fUI: ICrudUI<TEntry, TListEntry, TId>;
    fConfig: IEntryCrudConfig<TEntry, TListEntry, TId>;
    fNewEntryStarted: Boolean;
    fCurrentEntry: TEntry;
    fDataChanged: Boolean;
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aId: TId): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    procedure StartNewEntry;
    function DeleteEntry(const aId: TId): TCrudCommandResult;
    function GetDataChanged: Boolean;
  public
    constructor Create(const aUI: ICrudUI<TEntry, TListEntry, TId>; const aConfig: IEntryCrudConfig<TEntry, TListEntry, TId>);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils;

{ TCrudBusiness<TEntry, TListEntry, TId> }

constructor TCrudBusiness<TEntry, TListEntry, TId>.Create(const aUI: ICrudUI<TEntry, TListEntry, TId>;
  const aConfig: IEntryCrudConfig<TEntry, TListEntry, TId>);
begin
  inherited Create;
  fUI := aUI;
  fConfig := aConfig;
end;

destructor TCrudBusiness<TEntry, TListEntry, TId>.Destroy;
begin
  fConfig.DestroyEntry(fCurrentEntry);
  fConfig := nil;
  fUI := nil;
  inherited;
end;

function TCrudBusiness<TEntry, TListEntry, TId>.GetDataChanged: Boolean;
begin
  Result := fDataChanged;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId>.Initialize;
begin
  var lCrudCommands: ICrudCommands<TId>;
  if not Supports(Self, ICrudCommands<TId>, lCrudCommands) then
    raise ENotImplemented.Create('ICrudCommands<TId> is not implemented.');

  fUI.SetCrudCommands(lCrudCommands)
end;

function TCrudBusiness<TEntry, TListEntry, TId>.LoadList: TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fNewEntryStarted := False;
  fUI.ClearEntryFromUI;
  fUI.ListEnumBegin;
  try
    var lSqlResult := fConfig.GetListSqlResult;
    while lSqlResult.Next do
    begin
      var lEntry := fConfig.GetListEntryFromSqlResult(lSqlResult);
      try
        if fConfig.IsEntryValidForList(lEntry) then
          fUI.ListEnumProcessItem(lEntry);
      finally
        fConfig.DestroyListEntry(lEntry);
      end;
    end;
  finally
    fUI.ListEnumEnd;
  end;
end;

function TCrudBusiness<TEntry, TListEntry, TId>.LoadCurrentEntry(const aId: TId): TCrudCommandResult;
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

function TCrudBusiness<TEntry, TListEntry, TId>.SaveCurrentEntry: TCrudSaveResult;
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
      fDataChanged := True;
    end;
  finally
    if lDestroyTempSavingEntry then
      fConfig.DestroyEntry(lTempSavingEntry);
  end;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId>.StartNewEntry;
begin
  fNewEntryStarted := True;
  fUI.ClearEntryFromUI;
end;

function TCrudBusiness<TEntry, TListEntry, TId>.ReloadCurrentEntry: TCrudCommandResult;
begin
  fUI.SetEntryToUI(fCurrentEntry, False);
end;

function TCrudBusiness<TEntry, TListEntry, TId>.DeleteEntry(const aId: TId): TCrudCommandResult;
begin

end;

end.
