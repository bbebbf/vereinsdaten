unit CrudBusiness;

interface

uses InterfacedBase, SqlConnection, CrudCommands, CrudUI, EntryCrudConfig, Vdm.Versioning.Types;

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

    procedure AssignVersionInfoEntry(const aSourceEntry, aTargetEntry: TEntry);
    procedure SetVersionInfoEntryToUI(const aEntry: TEntry);
    procedure ClearVersionInfoEntryFromUI;
  public
    constructor Create(const aUI: ICrudUI<TEntry, TListEntry, TId, TListFilter>; const aConfig: IEntryCrudConfig<TEntry, TListEntry, TId, TListFilter>);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, VersionInfoEntryAccessor, VersionInfoEntryUI, ProgressIndicatorIntf;

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
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, fConfig.GetEntryTitle(True) + ' werden geladen ...');
  Result := default(TCrudCommandResult);
  fNewEntryStarted := True;
  fUI.ClearEntryFromUI;
  fUI.ListEnumBegin;
  try
    var lSqlResult := fConfig.GetListSqlResult;
    while lSqlResult.Next do
    begin
      var lEntry := fConfig.GetListEntryFromSqlResult(lSqlResult);
      try
        if fConfig.IsEntryValidForList(lEntry, fListFilter) then
        begin
          fUI.ListEnumProcessItem(lEntry);
          fNewEntryStarted := True;
        end;
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
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, fConfig.GetEntryTitle(False) + ' wird geladen ...');
  fConfig.DestroyEntry(fCurrentEntry);
  fNewEntryStarted := False;
  if fConfig.TryLoadEntry(aId, fCurrentEntry) then
  begin
    fUI.SetEntryToUI(fCurrentEntry, TEntryToUIMode.OnLoadCurrentEntry);
    SetVersionInfoEntryToUI(fCurrentEntry);
  end
  else
  begin
    fUI.ClearEntryFromUI;
    fUI.DeleteEntryFromUI(aId);
    ClearVersionInfoEntryFromUI;
  end;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.SaveCurrentEntry: TCrudSaveResult;
begin
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, fConfig.GetEntryTitle(False) + ' wird gespeichert ...');
  Result := default(TCrudSaveResult);
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

    var lResponse := fConfig.SaveEntry(lTempSavingEntry);
    if fNewEntryStarted then
    begin
      SetVersionInfoEntryToUI(lTempSavingEntry);
    end
    else
    begin
      AssignVersionInfoEntry(lTempSavingEntry, fCurrentEntry);
    end;
    var lEntryToUI := TEntryToUIMode.OnUpdatedExistingEntry;
    if fNewEntryStarted then
      lEntryToUI := TEntryToUIMode.OnCreatedNewEntry;
    if lResponse.Status = TCrudSaveStatus.Successful then
    begin
      fConfig.DestroyEntry(fCurrentEntry);
      fCurrentEntry := lTempSavingEntry;
      lDestroyTempSavingEntry := False;
      fUI.SetEntryToUI(fCurrentEntry, lEntryToUI);
      SetVersionInfoEntryToUI(fCurrentEntry);
      if fNewEntryStarted then
      begin
        fConfig.NewEntrySaved(fCurrentEntry);
      end;
      fNewEntryStarted := False;
      fDataChanged := True;
    end
    else if lResponse.Status = TCrudSaveStatus.CancelledOnConflict then
    begin
      fUI.SetEntryToUI(fCurrentEntry, lEntryToUI);
      SetVersionInfoEntryToUI(fCurrentEntry);
      Exit(lResponse);
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
  ClearVersionInfoEntryFromUI;
  fConfig.StartNewEntry;
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.ReloadCurrentEntry: TCrudCommandResult;
begin
  LoadCurrentEntry(fConfig.GetIdFromEntry(fCurrentEntry));
end;

function TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.DeleteEntry(const aId: TId): TCrudCommandResult;
begin

end;

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.SetVersionInfoEntryToUI(
  const aEntry: TEntry);
begin
  if fConfig.IsEntryUndefined(aEntry) then
    Exit;

  var lVersionInfoEntryAccessor: IVersionInfoEntryAccessor<TEntry>;
  if Supports(fConfig, IVersionInfoEntryAccessor<TEntry>, lVersionInfoEntryAccessor) then
  begin
    var lVersionInfoEntry: TVersionInfoEntry;
    if lVersionInfoEntryAccessor.GetVersionInfoEntry(aEntry, lVersionInfoEntry) then
    begin
      var lVersionInfoEntryUI: IVersionInfoEntryUI;
      if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
        lVersionInfoEntryUI.SetVersionInfoEntryToUI(lVersionInfoEntry);
    end;
  end;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.AssignVersionInfoEntry(const aSourceEntry,
  aTargetEntry: TEntry);
begin
  var lVersionInfoEntryAccessor: IVersionInfoEntryAccessor<TEntry>;
  if Supports(fConfig, IVersionInfoEntryAccessor<TEntry>, lVersionInfoEntryAccessor) then
  begin
    lVersionInfoEntryAccessor.AssignVersionInfoEntry(aSourceEntry, aTargetEntry);
  end;
end;

procedure TCrudBusiness<TEntry, TListEntry, TId, TListFilter>.ClearVersionInfoEntryFromUI;
begin
  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
    lVersionInfoEntryUI.ClearVersionInfoEntryFromUI;
end;

end.
