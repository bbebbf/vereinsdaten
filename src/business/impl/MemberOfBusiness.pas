unit MemberOfBusiness;

interface

uses System.Classes, System.SysUtils, SqlConnection, CrudCommands, MemberOfBusinessIntf, PersonMemberOfUI,
  ProgressObserver, KeyIndexMapper, CrudConfig, ListEnumerator,
  DtoMemberAggregated, DtoMember, DtoUnit, DtoRole, ListCrudCommands, SelectList, SelectListFilter;

type
  TMemberOfBusinessRecordFilter = record
    ShowInactiveMemberOfs: Boolean;
  end;

  TMemberOfBusiness = class(TInterfacedObject, IMemberOfBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fProgressObserver: IProgressObserver;
    fUI: IPersonMemberOfUI;
    fMemberConfig: ICrudConfig<TDtoMember, UInt32>;
    fMemberConfigSelectListFilter: ISelectListFilter<TDtoMember, UInt32>;
    fListCrudCommands: TObjectListCrudCommands<TDtoMember, TDtoMemberAggregated, UInt32, TMemberOfBusinessRecordFilter>;
    fUnitMapper: TKeyIndexMapper<UInt32>;
    fUnitListConfig: ISelectList<TDtoUnit>;
    fRoleMapper: TKeyIndexMapper<UInt32>;
    fRoleListConfig: ISelectList<TDtoRole>;
    fCurrentPersonId: UInt32;
    fCurrentFilter: TMemberOfBusinessRecordFilter;
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
    function SaveCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudSaveRecordResult;
    function ReloadCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
    function DeleteRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
    procedure LoadAvailableUnits(const aStrings: TStrings);
    procedure LoadAvailableRoles(const aStrings: TStrings);
    procedure LoadPersonsMemberOfs(const aPersonId: UInt32);
    function GetUnitMapperIndex(const aUnitId: UInt32): Integer;
    function GetRoleMapperIndex(const aRoleId: UInt32): Integer;
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);

    function CreateMemberAggregated(aSource: TDtoMember): TDtoMemberAggregated;
    procedure OnItemMatchesFilter(Sender: TObject;
      const aItem: TDtoMember; const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
  public
    constructor Create(const aConnection: ISqlConnection; const aUI: IPersonMemberOfUI;
      const aProgressObserver: IProgressObserver);
    destructor Destroy; override;
  end;

implementation

uses CrudMemberConfig, CrudConfigUnit, CrudConfigRole;

{ TMemberOfBusiness }

constructor TMemberOfBusiness.Create(const aConnection: ISqlConnection; const aUI: IPersonMemberOfUI;
  const aProgressObserver: IProgressObserver);
begin
  inherited Create;
  fConnection := aConnection;
  fProgressObserver := aProgressObserver;
  fUI := aUI;
  fMemberConfig := TCrudMemberConfig.Create;
  Supports(fMemberConfig, ISelectListFilter<TDtoMember, UInt32>, fMemberConfigSelectListFilter);
  fListCrudCommands := TObjectListCrudCommands<TDtoMember, TDtoMemberAggregated, UInt32, TMemberOfBusinessRecordFilter>.Create(
    fConnection, fMemberConfigSelectListFilter, CreateMemberAggregated);
  fListCrudCommands.TargetEnumerator := fUI;
  fListCrudCommands.OnItemMatchesFilter := OnItemMatchesFilter;
  fUnitListConfig := TCrudConfigUnit.Create;
  fUnitMapper := TKeyIndexMapper<UInt32>.Create(0);
  fRoleListConfig := TCrudConfigRole.Create;
  fRoleMapper := TKeyIndexMapper<UInt32>.Create(0);
end;

destructor TMemberOfBusiness.Destroy;
begin
  fRoleMapper.Free;
  fUnitMapper.Free;
  fListCrudCommands.Free;
  inherited;
end;

function TMemberOfBusiness.GetRoleMapperIndex(const aRoleId: UInt32): Integer;
begin
  Result := fRoleMapper.GetIndex(aRoleId);
end;

function TMemberOfBusiness.GetShowInactiveMemberOfs: Boolean;
begin
  Result := fCurrentFilter.ShowInactiveMemberOfs;
end;

function TMemberOfBusiness.GetUnitMapperIndex(const aUnitId: UInt32): Integer;
begin
  Result := fUnitMapper.GetIndex(aUnitId);
end;

function TMemberOfBusiness.CreateMemberAggregated(aSource: TDtoMember): TDtoMemberAggregated;
begin
  Result := TDtoMemberAggregated.Create(aSource);
end;

procedure TMemberOfBusiness.Initialize;
begin
  fUI.Initialize(Self);
end;

procedure TMemberOfBusiness.LoadAvailableRoles(const aStrings: TStrings);
begin
  aStrings.BeginUpdate;
  try
    fRoleMapper.Clear;
    aStrings.Clear;
    aStrings.Add('<Rolle auswählen>');
    var lSqlResult := fConnection.GetSelectResult(fRoleListConfig.GetSelectListSQL);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoRole);
      fRoleListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      fRoleMapper.Add(lRecord.Id, aStrings.Add(lRecord.ToString));
    end;
  finally
    aStrings.EndUpdate;
  end;
end;

procedure TMemberOfBusiness.LoadAvailableUnits(const aStrings: TStrings);
begin
  aStrings.BeginUpdate;
  try
    fUnitMapper.Clear;
    aStrings.Clear;
    aStrings.Add('<Einheit auswählen>');
    var lSqlResult := fConnection.GetSelectResult(fUnitListConfig.GetSelectListSQL);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoUnit);
      fUnitListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      fUnitMapper.Add(lRecord.Id, aStrings.Add(lRecord.ToString));
    end;
  finally
    aStrings.EndUpdate;
  end;
end;

function TMemberOfBusiness.LoadCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
begin

end;

function TMemberOfBusiness.LoadList: TCrudCommandResult;
begin
  fListCrudCommands.BeginUpdateFilter;
  fListCrudCommands.FilterSelect := fCurrentPersonId;
  fListCrudCommands.FilterLoop := fCurrentFilter;
  fListCrudCommands.EndUpdateFilter;
end;

function TMemberOfBusiness.ReloadCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
begin

end;

function TMemberOfBusiness.SaveCurrentRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudSaveRecordResult;
begin

end;

procedure TMemberOfBusiness.SetShowInactiveMemberOfs(const aValue: Boolean);
begin
  if fCurrentFilter.ShowInactiveMemberOfs = aValue then
    Exit;

  fCurrentFilter.ShowInactiveMemberOfs := aValue;
  LoadList;
end;

function TMemberOfBusiness.DeleteRecord(const aRecordIdentity: TDtoMemberAggregated): TCrudCommandResult;
begin

end;

procedure TMemberOfBusiness.LoadPersonsMemberOfs(const aPersonId: UInt32);
begin
  if fCurrentPersonId = aPersonId then
    Exit;

  fCurrentPersonId := aPersonId;
  LoadList;
end;

procedure TMemberOfBusiness.OnItemMatchesFilter(Sender: TObject; const aItem: TDtoMember;
  const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
begin
  aItemMatches := aItem.Active or aFilter.ShowInactiveMemberOfs;
end;

end.
