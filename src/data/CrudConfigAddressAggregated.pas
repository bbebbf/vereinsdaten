unit CrudConfigAddressAggregated;

interface

uses InterfacedBase, EntryCrudConfig, DtoAddressAggregated, SqlConnection, CrudConfigAddress, CrudConfig,
  RecordActions, DtoAddress;

type
  TCrudConfigAddressAggregated = class(TInterfacedBase, IEntryCrudConfig<TDtoAddressAggregated, TDtoAddress, UInt32>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TDtoAddress, UInt32>;
    fRecordActions: TRecordActions<TDtoAddress, UInt32>;
    fMemberSelectQuery: ISqlPreparedQuery;
    function GetListSqlResult: ISqlResult;
    function GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoAddress;
    function IsEntryValidForList(const aEntry: TDtoAddress): Boolean;
    function IsEntryValidForSaving(const aEntry: TDtoAddressAggregated): Boolean;
    procedure DestroyEntry(var aEntry: TDtoAddressAggregated);
    procedure DestroyListEntry(var aEntry: TDtoAddress);
    function TryLoadEntry(const aId: UInt32; out aEntry: TDtoAddressAggregated): Boolean;
    function CreateEntry: TDtoAddressAggregated;
    function CloneEntry(const aEntry: TDtoAddressAggregated): TDtoAddressAggregated;
    function IsEntryUndefined(const aEntry: TDtoAddressAggregated): Boolean;
    function SaveEntry(var aEntry: TDtoAddressAggregated): Boolean;
    function DeleteEntry(const aId: UInt32): Boolean;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, SelectList;

{ TCrudConfigAddressAggregated }

constructor TCrudConfigAddressAggregated.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
  fCrudConfig := TCrudConfigAddress.Create;
  fRecordActions := TRecordActions<TDtoAddress, UInt32>.Create(fConnection, fCrudConfig);
end;

destructor TCrudConfigAddressAggregated.Destroy;
begin
  fRecordActions.Free;
  inherited;
end;

function TCrudConfigAddressAggregated.CloneEntry(const aEntry: TDtoAddressAggregated): TDtoAddressAggregated;
begin
  Result := TDtoAddressAggregated.Create(aEntry.Address);
end;

function TCrudConfigAddressAggregated.CreateEntry: TDtoAddressAggregated;
begin
  Result := TDtoAddressAggregated.Create(default(TDtoAddress));
end;

function TCrudConfigAddressAggregated.DeleteEntry(const aId: UInt32): Boolean;
begin
  Result := False;
end;

procedure TCrudConfigAddressAggregated.DestroyEntry(var aEntry: TDtoAddressAggregated);
begin
  FreeAndNil(aEntry);
end;

procedure TCrudConfigAddressAggregated.DestroyListEntry(var aEntry: TDtoAddress);
begin
  aEntry := default(TDtoAddress);
end;

function TCrudConfigAddressAggregated.GetListEntryFromSqlResult(const aSqlResult: ISqlResult): TDtoAddress;
begin
  Result := default(TDtoAddress);
  fCrudConfig.GetRecordFromSqlResult(aSqlResult, Result);
end;

function TCrudConfigAddressAggregated.GetListSqlResult: ISqlResult;
begin
  var lSelectList: ISelectList<TDtoAddress>;
  if not Supports(fCrudConfig, ISelectList<TDtoAddress>, lSelectList) then
    raise ENotImplemented.Create('fCrudConfig must implement ISelectList<TDtoAddress>.');
  Result := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
end;

function TCrudConfigAddressAggregated.IsEntryUndefined(const aEntry: TDtoAddressAggregated): Boolean;
begin
  Result := not Assigned(aEntry);
end;

function TCrudConfigAddressAggregated.IsEntryValidForList(const aEntry: TDtoAddress): Boolean;
begin
  Result := True;
end;

function TCrudConfigAddressAggregated.IsEntryValidForSaving(const aEntry: TDtoAddressAggregated): Boolean;
begin
  Result := True;
end;

function TCrudConfigAddressAggregated.SaveEntry(var aEntry: TDtoAddressAggregated): Boolean;
begin
  Result := True;
  var lRecord := aEntry.Address;
  if fRecordActions.SaveRecord(lRecord) = TRecordActionsSaveResponse.Created then
  begin
    aEntry.Id := lRecord.Id;
  end;
end;

function TCrudConfigAddressAggregated.TryLoadEntry(const aId: UInt32; out aEntry: TDtoAddressAggregated): Boolean;
begin
  var lRecord := default(TDtoAddress);
  Result := fRecordActions.LoadRecord(aId, lRecord);
  if not Result then
    Exit;

  aEntry := TDtoAddressAggregated.Create(lRecord);

  if not Assigned(fMemberSelectQuery) then
  begin
    fMemberSelectQuery := fConnection.CreatePreparedQuery(
        'SELECT p.person_id, p.person_vorname, p.person_praeposition, p.person_nachname, p.person_active' +
        ' FROM `person_address` AS pa' +
        ' INNER JOIN `person` AS p ON p.person_id = pa.person_id' +
        ' WHERE pa.adr_id = :AdrId' +
        ' ORDER BY p.person_active DESC, p.person_nachname, p.person_vorname'
      );
  end;
  fMemberSelectQuery.ParamByName('AdrId').Value := lRecord.Id;
  var lSqlResult := fMemberSelectQuery.Open;
  while lSqlResult.Next do
  begin
    var lMemberRec := default(TDtoAddressAggregatedPersonMemberOf);
    lMemberRec.PersonNameId.Id := lSqlResult.FieldByName('person_id').AsLargeInt;
    lMemberRec.PersonNameId.Vorname := lSqlResult.FieldByName('person_vorname').AsString;
    lMemberRec.PersonNameId.Praeposition := lSqlResult.FieldByName('person_praeposition').AsString;
    lMemberRec.PersonNameId.Nachname := lSqlResult.FieldByName('person_nachname').AsString;
    lMemberRec.PersonActive := lSqlResult.FieldByName('person_active').AsBoolean;
    aEntry.MemberOfList.Add(lMemberRec);
  end;
end;

end.
