unit MemberOfBusiness;

interface

uses System.Classes, System.Generics.Collections, InterfacedBase, SqlConnection, MemberOfBusinessIntf,
  MemberOfUI, KeyIndexStrings, CrudConfig, FilterSelect, Transaction,
  DtoMemberAggregated, DtoMember, DtoUnit, DtoRole, ListCrudCommands, SelectList, SelectListFilter,
  ValueConverter, Vdm.Types, Vdm.Versioning.Types, VersionInfoAccessor;

type
  TMemberOfBusinessRecordFilter = record
    ShowInactiveMemberOfs: Boolean;
  end;

  TMemberOfBusiness = class(TInterfacedBase, IMemberOfBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fMemberOfMaster: TMemberOfMaster;
    fUI: IMemberOfUI;
    fMemberConfig: ICrudConfig<TDtoMember, UInt32>;
    fListCrudCommands: TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated, UInt32, TMemberOfBusinessRecordFilter>;
    fVersionInfoMemberOfsConfig: IVersionInfoConfig<UInt32, UInt32>;
    fVersionInfoAccessor: TVersionInfoAccessor<UInt32, UInt32>;
    fTransactionScopeLoadEntries: IVersionInfoAccessorTransactionScope;
    fUnitMapper: TKeyIndexStrings;
    fUnitListConfig: ISelectList<TDtoUnit>;
    fRoleMapper: TKeyIndexStrings;
    fRoleListConfig: ISelectList<TDtoRole>;
    fCurrentMasterId: UInt32;
    fCurrentMemberOfsVersionEntry: TVersionInfoEntry;
    fCurrentFilter: TMemberOfBusinessRecordFilter;
    fSelectListFilter: ISelectListFilter<TDtoMember, UInt32>;
    fValueConverter: IValueConverter<TDtoMember, TDtoMemberAggregated>;
    procedure Initialize;
    function GetMemberOfMaster: TMemberOfMaster;
    procedure LoadMemberOfs(const aMasterId: UInt32; const aMemberOfsVersionInfoEntry: TVersionInfoEntry);
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);
    function CreateNewEntry: TListEntry<TDtoMemberAggregated>;
    procedure AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
    procedure ReloadEntries;
    procedure SaveEntries(const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>);
    procedure ClearUnitCache;
    procedure ClearRoleCache;

    procedure UpdateFilter;
    procedure OnItemMatchesFilter(Sender: TObject;
      const aItem: TDtoMember; const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
    procedure OnFilterSelectTransaction(Sender: TObject; const aState: TFilterSelectTransactionEventState;
        var aTransaction: ITransaction);
    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry);
    procedure ClearVersionInfoEntryFromUI;
  public
    constructor Create(const aConnection: ISqlConnection; const aMemberOfMaster: TMemberOfMaster; const aUI: IMemberOfUI);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, CrudMemberConfig, CrudConfigUnit, CrudConfigRole, KeyIndexMapper,
  VersionInfoEntryUI;

type
  TDtoMemberConverter = class(TInterfacedBase, IValueConverter<TDtoMember, TDtoMemberAggregated>)
  strict private
    fUnitMapper: TKeyIndexStrings;
    fRoleMapper: TKeyIndexStrings;
    procedure Convert(const aValue: TDtoMember; var aTarget: TDtoMemberAggregated);
    procedure ConvertBack(const aValue: TDtoMemberAggregated; var aTarget: TDtoMember);
  public
    constructor Create(const aUnitMapper, aRoleMapper: TKeyIndexStrings);
  end;

  TPersonMemberOfsVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<UInt32, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: UInt32): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;


{ TMemberOfBusiness }

constructor TMemberOfBusiness.Create(const aConnection: ISqlConnection; const aMemberOfMaster: TMemberOfMaster; const aUI: IMemberOfUI);
begin
  inherited Create;
  fConnection := aConnection;
  fMemberOfMaster := aMemberOfMaster;
  fUI := aUI;
  fMemberConfig := TCrudMemberConfig.Create;

  if not Supports(fMemberConfig, ISelectListFilter<TDtoMember, UInt32>, fSelectListFilter) then
    raise ENotSupportedException.Create('aCrudConfig doesn''t support ISelectListFilter.');

  fUnitListConfig := TCrudConfigUnit.Create;
  fRoleListConfig := TCrudConfigRole.Create;
  fUnitMapper := TKeyIndexStrings.Create(
      function(var aData: TKeyIndexStringsData): Boolean
      begin
        Result := True;
        aData := TKeyIndexStringsData.Create;
        try
          aData.BeginUpdate;
          var lSqlResult := fConnection.GetSelectResult(fUnitListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoUnit);
            fUnitListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.AddMappedString(lRecord.Id, lRecord.ToString);
          end;
        finally
          aData.EndUpdate;
        end;
      end
    );
  fRoleMapper := TKeyIndexStrings.Create(
      function(var aData: TKeyIndexStringsData): Boolean
      begin
        Result := True;
        aData := TKeyIndexStringsData.Create;
        try
          aData.BeginUpdate;
          var lSqlResult := fConnection.GetSelectResult(fRoleListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoRole);
            fRoleListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.AddMappedString(lRecord.Id, lRecord.ToString);
          end;
        finally
          aData.EndUpdate;
        end;
      end
    );

  fValueConverter := TDtoMemberConverter.Create(fUnitMapper, fRoleMapper);
  fListCrudCommands := TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated,
    UInt32, TMemberOfBusinessRecordFilter>.Create(
    fConnection, fSelectListFilter, fMemberConfig, fValueConverter);
  fListCrudCommands.TargetEnumerator := fUI;
  fListCrudCommands.OnItemMatchesFilter := OnItemMatchesFilter;
  fListCrudCommands.OnTransaction := OnFilterSelectTransaction;

  fVersionInfoMemberOfsConfig := TPersonMemberOfsVersionInfoConfig.Create;
  fVersionInfoAccessor := TVersionInfoAccessor<UInt32, UInt32>.Create(fConnection, fVersionInfoMemberOfsConfig);
end;

destructor TMemberOfBusiness.Destroy;
begin
  fVersionInfoAccessor.Free;
  fListCrudCommands.Free;
  fValueConverter := nil;
  fRoleMapper.Free;
  fUnitMapper.Free;
  fRoleListConfig := nil;
  fUnitListConfig := nil;
  fSelectListFilter := nil;
  fMemberConfig := nil;
  fUI := nil;
  fConnection := nil;
  inherited;
end;

procedure TMemberOfBusiness.ClearRoleCache;
begin
  fRoleMapper.Invalidate;
end;

procedure TMemberOfBusiness.ClearUnitCache;
begin
  fUnitMapper.Invalidate;
end;

function TMemberOfBusiness.GetMemberOfMaster: TMemberOfMaster;
begin
  Result := fMemberOfMaster;
end;

function TMemberOfBusiness.GetShowInactiveMemberOfs: Boolean;
begin
  Result := fCurrentFilter.ShowInactiveMemberOfs;
end;

function TMemberOfBusiness.CreateNewEntry: TListEntry<TDtoMemberAggregated>;
begin
  Result := TObjectListEntry<TDtoMemberAggregated>.CreateNew(TDtoMemberAggregated.Create(fUnitMapper, fRoleMapper));
  Result.Data.Active := True;
end;

procedure TMemberOfBusiness.AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
begin
  aEntry.Data.PersonId := fCurrentMasterId;
  fListCrudCommands.Items.Add(aEntry);
end;

procedure TMemberOfBusiness.Initialize;
begin
  fUI.SetCommands(Self);
end;

procedure TMemberOfBusiness.SetShowInactiveMemberOfs(const aValue: Boolean);
begin
  if fCurrentFilter.ShowInactiveMemberOfs = aValue then
    Exit;

  fCurrentFilter.ShowInactiveMemberOfs := aValue;
  UpdateFilter;
end;

procedure TMemberOfBusiness.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry);
begin
  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
    lVersionInfoEntryUI.SetVersionInfoEntryToUI(aVersionInfoEntry);
end;

procedure TMemberOfBusiness.ClearVersionInfoEntryFromUI;
begin
  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
    lVersionInfoEntryUI.ClearVersionInfoEntryFromUI;
end;

procedure TMemberOfBusiness.UpdateFilter;
begin
  fListCrudCommands.BeginUpdateFilter;
   fListCrudCommands.FilterSelect := fCurrentMasterId;
  fListCrudCommands.FilterLoop := fCurrentFilter;
  fListCrudCommands.EndUpdateFilter;
end;

procedure TMemberOfBusiness.LoadMemberOfs(const aMasterId: UInt32; const aMemberOfsVersionInfoEntry: TVersionInfoEntry);
begin
  if fCurrentMasterId = aMasterId then
    Exit;

  fCurrentMasterId := aMasterId;
  fCurrentMemberOfsVersionEntry := aMemberOfsVersionInfoEntry;
  UpdateFilter;
end;

procedure TMemberOfBusiness.OnFilterSelectTransaction(Sender: TObject; const aState: TFilterSelectTransactionEventState;
  var aTransaction: ITransaction);
begin
  if not Assigned(fCurrentMemberOfsVersionEntry) or (fCurrentMasterId = 0) then
  begin
    fTransactionScopeLoadEntries := nil;
    aTransaction := nil;
    ClearVersionInfoEntryFromUI;
    Exit;
  end;
  case aState of
    TFilterSelectTransactionEventState.StartTransaction:
    begin
      fTransactionScopeLoadEntries := fVersionInfoAccessor.StartTransaction;
      aTransaction := fTransactionScopeLoadEntries.Transaction;
    end;
    TFilterSelectTransactionEventState.EndTransactionSuccessful:
    begin
      fCurrentMemberOfsVersionEntry.UpdateVersionInfo(
        fVersionInfoAccessor.QueryVersionInfo(fTransactionScopeLoadEntries, fCurrentMasterId));
      fTransactionScopeLoadEntries.Transaction.Commit;
      fTransactionScopeLoadEntries := nil;
      SetVersionInfoEntryToUI(fCurrentMemberOfsVersionEntry);
    end;
    TFilterSelectTransactionEventState.EndTransactionException:
    begin
      fTransactionScopeLoadEntries.Transaction.Rollback;
      fTransactionScopeLoadEntries := nil;
      SetVersionInfoEntryToUI(fCurrentMemberOfsVersionEntry);
    end;
  end;
end;

procedure TMemberOfBusiness.OnItemMatchesFilter(Sender: TObject; const aItem: TDtoMember;
  const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
begin
  aItemMatches := aItem.Active or aFilter.ShowInactiveMemberOfs;
end;

procedure TMemberOfBusiness.SaveEntries(
  const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>);
begin
  if Assigned(fCurrentMemberOfsVersionEntry) and (fCurrentMasterId > 0) then
  begin
    var lTransactionScopeSaveEntries := fVersionInfoAccessor.StartTransaction;
    fListCrudCommands.SaveChanges(aDeleteEntryCallback, lTransactionScopeSaveEntries.Transaction);
    fVersionInfoAccessor.UpdateVersionInfo(lTransactionScopeSaveEntries, fCurrentMasterId, fCurrentMemberOfsVersionEntry);
    SetVersionInfoEntryToUI(fCurrentMemberOfsVersionEntry);
  end
  else
  begin
    fListCrudCommands.SaveChanges(aDeleteEntryCallback);
    ClearVersionInfoEntryFromUI;
  end;
end;

procedure TMemberOfBusiness.ReloadEntries;
begin
  fListCrudCommands
  .Reload;
end;

{ TDtoMemberConverter }

constructor TDtoMemberConverter.Create(const aUnitMapper, aRoleMapper: TKeyIndexStrings);
begin
  inherited Create;
  fUnitMapper := aUnitMapper;
  fRoleMapper := aRoleMapper;
end;

procedure TDtoMemberConverter.Convert(const aValue: TDtoMember; var aTarget: TDtoMemberAggregated);
begin
  if Assigned(aTarget) then
  begin
    aTarget.UpdateByDtoMember(aValue);
  end
  else
  begin
    aTarget := TDtoMemberAggregated.Create(fUnitMapper, fRoleMapper, aValue);
  end;
end;

procedure TDtoMemberConverter.ConvertBack(const aValue: TDtoMemberAggregated; var aTarget: TDtoMember);
begin
  aTarget := aValue.Member;
end;

{ TPersonMemberOfsVersionInfoConfig }

function TPersonMemberOfsVersionInfoConfig.GetRecordIdentity(const aRecord: UInt32): UInt32;
begin
  Result := aRecord;
end;

function TPersonMemberOfsVersionInfoConfig.GetVersioningEntityId: TEntryVersionInfoEntity;
begin
  Result := TEntryVersionInfoEntity.PersonMemberOfs;
end;

function TPersonMemberOfsVersionInfoConfig.GetVersioningIdentityColumnName: string;
begin
  Result := 'person_id';
end;

procedure TPersonMemberOfsVersionInfoConfig.SetVersionInfoParameter(const aRecordIdentity: UInt32;
  const aParameter: ISqlParameter);
begin
  aParameter.Value := aRecordIdentity;
end;

end.
