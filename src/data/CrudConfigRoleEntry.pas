unit CrudConfigRoleEntry;

interface

uses InterfacedBase, EntryCrudConfig, SqlConnection, CrudConfigRole, CrudConfig, DtoRole, RecordActions,
  Vdm.Types, CrudCommands;

type
  TCrudConfigRoleEntry = class(TInterfacedBase, IEntryCrudConfig<TDtoRole, TDtoRole, UInt32, TEntryFilter>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TDtoRole, UInt32>;
    fRecordActions: TRecordActions<TDtoRole, UInt32>;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoRole;
    function IsEntryValidForList(const aEntry: TDtoRole; const aListFilter: TEntryFilter): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoRole): Boolean;
    procedure DestroyEntry(var aEntry: TDtoRole);
    procedure DestroyListEntry(var aEntry: TDtoRole);
    procedure StartNewEntry;
    procedure NewEntrySaved(const aEntry: TDtoRole);
    function GetIdFromEntry(const aEntry: TDtoRole): UInt32;
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoRole): Boolean;
    function CreateEntry: TDtoRole;
    function CloneEntry(const aEntry: TDtoRole): TDtoRole;
    function IsEntryUndefined(const aEntry: TDtoRole): Boolean;
    function SaveEntry(var aEntry: TDtoRole): TCrudSaveResult;
    function DeleteEntry(const aId: UInt32): Boolean;
    function GetEntryTitle(const aPlural: Boolean): string;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList;

{ TCrudConfigRoleEntry }

constructor TCrudConfigRoleEntry.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfig := TCrudConfigRole.Create;
  fRecordActions := TRecordActions<TDtoRole, UInt32>.Create(fConnection, fCrudConfig);
end;

destructor TCrudConfigRoleEntry.Destroy;
begin
  fRecordActions.Free;
  fCrudConfig := nil;
  inherited;
end;

function TCrudConfigRoleEntry.CloneEntry(const aEntry: TDtoRole): TDtoRole;
begin
  Result := aEntry;
end;

function TCrudConfigRoleEntry.CreateEntry: TDtoRole;
begin
  Result := default(TDtoRole);
end;

function TCrudConfigRoleEntry.DeleteEntry(const aId: UInt32): Boolean;
begin
  Result := False;
end;

procedure TCrudConfigRoleEntry.DestroyEntry(var aEntry: TDtoRole);
begin
  aEntry := default(TDtoRole);
end;

procedure TCrudConfigRoleEntry.DestroyListEntry(var aEntry: TDtoRole);
begin
  aEntry := default(TDtoRole);
end;

function TCrudConfigRoleEntry.GetEntryTitle(const aPlural: Boolean): string;
begin
  if aPlural then
    Result := 'Rollen'
  else
    Result := 'Rolle';
end;

function TCrudConfigRoleEntry.GetIdFromEntry(const aEntry: TDtoRole): UInt32;
begin
  Result := aEntry.Id;
end;

function TCrudConfigRoleEntry.GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoRole;
begin
  Result := default(TDtoRole);
  fCrudConfig.GetRecordFromSqlResult(aSqlResult, Result);
end;

function TCrudConfigRoleEntry.GetListSqlResult: ISqlResult;
begin
  var lSelectList: ISelectList<TDtoRole>;
  if not Supports(fCrudConfig, ISelectList<TDtoRole>, lSelectList) then
    raise ENotImplemented.Create('fCrudConfig must implement ISelectList<TDtoRole>.');
  Result := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
end;

function TCrudConfigRoleEntry.IsEntryUndefined(const aEntry: TDtoRole): Boolean;
begin
  Result := False;
end;

function TCrudConfigRoleEntry.IsEntryValidForList(const aEntry: TDtoRole; const aListFilter: TEntryFilter): Boolean;
begin
  Result := aEntry.Active or aListFilter.ShowInactiveEntries;
end;

function TCrudConfigRoleEntry.IsEntryValidForSaving(const aEntry: TDtoRole): Boolean;
begin
  Result := True;
end;

procedure TCrudConfigRoleEntry.NewEntrySaved(const aEntry: TDtoRole);
begin

end;

function TCrudConfigRoleEntry.SaveEntry(var aEntry: TDtoRole): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  if fRecordActions.SaveRecord(aEntry) = TRecordActionsSaveResponse.Created then
  begin
  end;
end;

procedure TCrudConfigRoleEntry.StartNewEntry;
begin

end;

function TCrudConfigRoleEntry.TryLoadEntry(const aId: UInt32; out aEntry: TDtoRole): Boolean;
begin
  Result := fRecordActions.LoadRecord(aId, aEntry);
end;

end.
