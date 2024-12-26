unit CrudConfigRoleEntry;

interface

uses InterfacedBase, EntryCrudConfig, SqlConnection, CrudConfigRole, CrudConfig, DtoRole, RecordActions;

type
  TCrudConfigRoleEntry = class(TInterfacedBase, IEntryCrudConfig<TDtoRole, TDtoRole, UInt32>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TDtoRole, UInt32>;
    fRecordActions: TRecordActions<TDtoRole, UInt32>;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoRole;
    function IsEntryValidForList(const aEntry: TDtoRole): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoRole): Boolean;
    procedure DestroyEntry(var aEntry: TDtoRole);
    procedure DestroyListEntry(var aEntry: TDtoRole);
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoRole): Boolean;
    function CreateEntry: TDtoRole;
    function CloneEntry(const aEntry: TDtoRole): TDtoRole;
    function IsEntryUndefined(const aEntry: TDtoRole): Boolean;
    function SaveEntry(var aEntry: TDtoRole): Boolean;
    function DeleteEntry(const aId: UInt32): Boolean;
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

function TCrudConfigRoleEntry.IsEntryValidForList(const aEntry: TDtoRole): Boolean;
begin
  Result := True;
end;

function TCrudConfigRoleEntry.IsEntryValidForSaving(const aEntry: TDtoRole): Boolean;
begin
  Result := True;
end;

function TCrudConfigRoleEntry.SaveEntry(var aEntry: TDtoRole): Boolean;
begin
  Result := True;
  if fRecordActions.SaveRecord(aEntry) = TRecordActionsSaveResponse.Created then
  begin
  end;
end;

function TCrudConfigRoleEntry.TryLoadEntry(const aId: UInt32; out aEntry: TDtoRole): Boolean;
begin
  Result := fRecordActions.LoadRecord(aId, aEntry);
end;

end.
