unit CrudConfigTenantEntry;

interface

uses InterfacedBase, EntryCrudConfig, SqlConnection, CrudConfigTenant, CrudConfig, DtoTenant, RecordActions,
  Vdm.Types, CrudCommands;

type
  TCrudConfigTenantEntry = class(TInterfacedBase, IEntryCrudConfig<TDtoTenant, TDtoTenant, UInt8, TVoid>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TDtoTenant, UInt8>;
    fRecordActions: TRecordActions<TDtoTenant, UInt8>;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoTenant;
    function IsEntryValidForList(const aEntry: TDtoTenant; const aListFilter: TVoid): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoTenant): Boolean;
    procedure DestroyEntry(var aEntry: TDtoTenant);
    procedure DestroyListEntry(var aEntry: TDtoTenant);
    procedure StartNewEntry;
    procedure NewEntrySaved(const aEntry: TDtoTenant);
    function GetIdFromEntry(const aEntry: TDtoTenant): UInt8;
    function TryLoadEntry(const aId: UInt8; out aEntry: TDtoTenant): Boolean;
    function CreateEntry: TDtoTenant;
    function CloneEntry(const aEntry: TDtoTenant): TDtoTenant;
    function IsEntryUndefined(const aEntry: TDtoTenant): Boolean;
    function SaveEntry(var aEntry: TDtoTenant): TCrudSaveResult;
    function DeleteEntry(const aId: UInt8): Boolean;
    function GetEntryTitle(const aPlural: Boolean): string;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList;

{ TCrudConfigTenantEntry }

constructor TCrudConfigTenantEntry.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfig := TCrudConfigTenant.Create;
  fRecordActions := TRecordActions<TDtoTenant, UInt8>.Create(fConnection, fCrudConfig);
end;

destructor TCrudConfigTenantEntry.Destroy;
begin
  fRecordActions.Free;
  fCrudConfig := nil;
  inherited;
end;

function TCrudConfigTenantEntry.CloneEntry(const aEntry: TDtoTenant): TDtoTenant;
begin
  Result := aEntry;
end;

function TCrudConfigTenantEntry.CreateEntry: TDtoTenant;
begin
  Result := default(TDtoTenant);
end;

function TCrudConfigTenantEntry.DeleteEntry(const aId: UInt8): Boolean;
begin
  Result := False;
end;

procedure TCrudConfigTenantEntry.DestroyEntry(var aEntry: TDtoTenant);
begin
  aEntry := default(TDtoTenant);
end;

procedure TCrudConfigTenantEntry.DestroyListEntry(var aEntry: TDtoTenant);
begin
  aEntry := default(TDtoTenant);
end;

function TCrudConfigTenantEntry.GetEntryTitle(const aPlural: Boolean): string;
begin
  Result := 'Vereinsdaten';
end;

function TCrudConfigTenantEntry.GetIdFromEntry(const aEntry: TDtoTenant): UInt8;
begin
  Result := aEntry.Id;
end;

function TCrudConfigTenantEntry.GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoTenant;
begin
  Result := default(TDtoTenant);
  fCrudConfig.GetRecordFromSqlResult(aSqlResult, Result);
end;

function TCrudConfigTenantEntry.GetListSqlResult: ISqlResult;
begin
  var lSelectList: ISelectList<TDtoTenant>;
  if not Supports(fCrudConfig, ISelectList<TDtoTenant>, lSelectList) then
    raise ENotImplemented.Create('fCrudConfig must implement ISelectList<TDtoTenant>.');
  Result := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
end;

function TCrudConfigTenantEntry.IsEntryUndefined(const aEntry: TDtoTenant): Boolean;
begin
  Result := False;
end;

function TCrudConfigTenantEntry.IsEntryValidForList(const aEntry: TDtoTenant; const aListFilter: TVoid): Boolean;
begin
  Result := True;
end;

function TCrudConfigTenantEntry.IsEntryValidForSaving(const aEntry: TDtoTenant): Boolean;
begin
  Result := True;
end;

procedure TCrudConfigTenantEntry.NewEntrySaved(const aEntry: TDtoTenant);
begin

end;

function TCrudConfigTenantEntry.SaveEntry(var aEntry: TDtoTenant): TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  if fRecordActions.SaveRecord(aEntry) = TRecordActionsSaveResponse.Created then
  begin
  end;
end;

procedure TCrudConfigTenantEntry.StartNewEntry;
begin

end;

function TCrudConfigTenantEntry.TryLoadEntry(const aId: UInt8; out aEntry: TDtoTenant): Boolean;
begin
  Result := fRecordActions.LoadRecord(aId, aEntry);
end;

end.
