unit CrudBusiness;

interface

uses InterfacedBase, SqlConnection, CrudCommands, CrudUI, EntryCrudConfig;

type
  TCrudBusiness<TEntry; TListEntry; TId, TListFilter: record> = class(TInterfacedBase, ICrudCommands<TId, TListFilter>)
  strict private
    fUI: ICrudUI<TEntry, TListEntry, TId, TListFilter>;
    fConfig: IEntryCrudConfig<TEntry, TListEntry, TId, TListFilter>;
    fNewEntryStarted: Boolean;
    fCurrentEntry: TEntry;
    fDataChanged: Boolean;
    fListFilter: TListFilter;
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aId: TId): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    procedure StartNewEntry;
    function DeleteEntry(const aId: TId): TCrudCommandResult;
    function GetDataChanged: Boolean;
    function GetListFilter: TListFilter;
    procedure SetListFilter(const aValue: TListFilter);
  public
    constructor Create(const aUI: ICrudUI<TEntry, TListEntry, TId, TListFilter>; const aConfig: IEntryCrudConfig<TEntry, TListEntry, TId, TListFilter>);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils;

{ TCrudBusiness<TEntry, TListEntry, TId, TListFilter> }

constructor TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.Create(const aUI: ICrudUI<TEntry, TListEntry, TId, TListFilter>;
  const aConfig: IEntryCrudConfig<TEntry, TListEntry, TId, TListFilter>);
begin
  inherited Create;
  fUI := aUI;
  fConfig := aConfig;
end;

destructor TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.Destroy;
begin
  fConfig.DestroyEntry(fCurrentEntry);
  fConfig := nil;
  fUI := nil;
  inherited;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.GetDataChanged: Boolean;
begin
  Result := fDataChanged;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.GetListFilter: TListFilter;
begin
  Result := fListFilter;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.Initialize;
begin
  var lCrudCommands: ICrudCommands<TId, TListFilter>;
  if not Supports(Self, ICrudCommands<TId, TListFilter>, lCrudCommands) then
    raise ENotImplemented.Create('ICrudCommands<TId, TListFilter> is not implemented.');

  fUI.SetCrudCommands(lCrudCommands)
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.LoadList: TCrudCommandResult;
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
        if fConfig.IsEntryValidForList(lEntry, fListFilter) then
          fUI.ListEnumProcessItem(lEntry);
      finally
        fConfig.DestroyListEntry(lEntry);
      end;
    end;
  finally
    fUI.ListEnumEnd;
  end;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.LoadCurrentEntry(const aId: TId): TCrudCommandResult;
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

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.SaveCurrentEntry: TCrudSaveResult;
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

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.SetListFilter(const aValue: TListFilter);
begin
  if CompareMem(@fListFilter, @aValue, SizeOf(TListFilter)) then
    Exit;
  fListFilter := aValue;
  LoadList;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.StartNewEntry;
begin
  fNewEntryStarted := True;
  fUI.ClearEntryFromUI;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.ReloadCurrentEntry: TCrudCommandResult;
begin
  fUI.SetEntryToUI(fCurrentEntry, False);
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.DeleteEntry(const aId: TId): TCrudCommandResult;
begin

end;

end.
