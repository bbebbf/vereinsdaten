﻿unit PersonBusiness;

interface

uses System.Classes, InterfacedBase, CrudCommands, CrudConfig, Transaction, PersonBusinessIntf,
  DtoPersonAggregated, SqlConnection, PersonAggregatedUI, DtoPerson, RecordActions, RecordActionsVersioning,
  KeyIndexStrings, DtoPersonAddress, DtoAddress, DtoClubmembership, DtoMember, ClubmembershipTools,
  MemberOfBusinessIntf, MemberOfConfigIntf, ProgressIndicatorIntf, Vdm.Types, Vdm.Versioning.Types, CrudUI,
  EntriesCrudEvents, DtoMemberAggregated;

type
  TPersonBusiness = class(TInterfacedBase, IPersonBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fProgressIndicator: IProgressIndicator;
    fPersonConfig: ICrudConfig<TDtoPerson, UInt32>;
    fPersonBaseVersionInfoConfig: IVersionInfoConfig<TDtoPerson, UInt32>;
    fPersonRecordActions: TRecordActionsVersioning<TDtoPerson, UInt32>;
    fPersonAddressConfig: ICrudConfig<TDtoPersonAddress, UInt32>;
    fPersonAddressRecordActions: TRecordActions<TDtoPersonAddress, UInt32>;
    fAddressConfig: ICrudConfig<TDtoAddress, UInt32>;
    fAddressRecordActions: TRecordActions<TDtoAddress, UInt32>;
    fClubmembershipConfig: ICrudConfig<TDtoClubmembership, UInt32>;
    fClubmembershipRecordActions: TRecordActions<TDtoClubmembership, UInt32>;
    fUI: IPersonAggregatedUI;
    fCurrentEntry: TDtoPersonAggregated;
    fNewEntryStarted: Boolean;
    fAddressMapper: TActiveKeyIndexStringsLoader;
    fShowInactivePersons: Boolean;
    fClubMembershipNumberChecker: TClubMembershipNumberChecker;
    fMemberOfConfig: IMemberOfConfigIntf;
    fMemberOfBusiness: IMemberOfBusinessIntf;
    fDataChanged: Boolean;
    fPersonMemberOfsVersionInfoAccessor: IPersonMemberOfsCrudEvents;

    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aPersonId: UInt32): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    procedure StartNewEntry;
    function DeleteEntry(const aPersonId: UInt32): TCrudCommandResult;
    function GetDataChanged: Boolean;
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);
    procedure LoadPersonsMemberOfs;
    procedure ClearAddressCache;
    function GetAvailableAddresses: TActiveKeyIndexStringsLoader;
    function GetListFilter: TVoid;
    procedure SetListFilter(const aValue: TVoid);
    function LoadPerson(const aPersonId: UInt32; const aLoadMemberOfs: Boolean): TCrudCommandResult;

    procedure SetCurrentEntryToUI(const aMode: TEntryToUIMode);
    procedure ClearEntryFromUI;
    procedure SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry);
    procedure ClearVersionInfoEntryFromUI;
  public
    constructor Create(const aConnection: ISqlConnection; const aUI: IPersonAggregatedUI;
      const aProgressIndicator: IProgressIndicator);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, System.Generics.Collections, SelectList, KeyIndexMapper,
  CrudConfigPerson, CrudConfigAddress, CrudConfigPersonAddress, CrudConfigClubmembership,
  MemberOfBusiness, EntryCrudConfig, CrudConfigUnitAggregated, CrudBusiness, CrudMemberConfigMasterPerson,
  VersionInfoEntryUI, VersionInfoAccessor, MemberOfVersionInfoConfig, PersonMapper;

type
  TPersonBasedataVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<TDtoPerson, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;

  TPersonMemberOfsVersionInfoAccessor = class(TInterfacedBase, IPersonMemberOfsCrudEvents)
  strict private
    fCurrentPersonEntry: TDtoPersonAggregated;
    fUI: IVersionInfoEntryUI;
    fVersionInfoConfig: IVersionInfoConfig<UInt32, UInt32>;
    fVersionInfoAccessor: TVersionInfoAccessor<UInt32, UInt32>;
    fVersionInfoAccessorTransactionScope: IVersionInfoAccessorTransactionScope;
    fConflictedVersionEntry: TVersionInfoEntry;
    procedure BeginLoadEntries(const aTransaction: ITransaction);
    procedure LoadEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure EndLoadEntries(const aTransaction: ITransaction);

    procedure BeginSaveEntries(const aTransaction: ITransaction);
    procedure SaveEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure DeleteEntry(const aEntry: TDtoMemberAggregated; const aTransaction: ITransaction);
    procedure EndSaveEntries(const aTransaction: ITransaction);

    function GetVersionConflictDetected: Boolean;
    function GetConflictedVersionEntry: TVersionInfoEntry;
    procedure SetCurrentPersonEntry(const aPersonEntry: TDtoPersonAggregated);
  public
    constructor Create(const aConnection: ISqlConnection; const aUI: IVersionInfoEntryUI);
    destructor Destroy; override;
  end;

{ TPersonBusiness }

constructor TPersonBusiness.Create(const aConnection: ISqlConnection; const aUI: IPersonAggregatedUI;
  const aProgressIndicator: IProgressIndicator);
begin
  inherited Create;
  fConnection := aConnection;
  fProgressIndicator := aProgressIndicator;
  fUI := aUI;
  fAddressMapper := TActiveKeyIndexStringsLoader.Create(
      function(var aData: TActiveKeyIndexStrings): Boolean
      begin
        Result := True;
        var lSelectList: ISelectList<TDtoAddress>;
        var lSqlResult: ISqlResult := nil;
        if not Supports(fAddressConfig, ISelectList<TDtoAddress>, lSelectList) then
          raise ENotImplemented.Create('fAddressConfig must implement ISelectList<TDtoAddress>.');
        aData := TActiveKeyIndexStrings.Create;
        lSqlResult := fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
        while lSqlResult.Next do
        begin
          var lRecord := default(TDtoAddress);
          fAddressConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
          aData.AddString(lRecord.Id, lRecord.Active, lRecord.ToString);
        end;
      end
  );
  fPersonConfig := TCrudConfigPerson.Create;
  fPersonBaseVersionInfoConfig := TPersonBasedataVersionInfoConfig.Create;
  fPersonRecordActions := TRecordActionsVersioning<TDtoPerson, UInt32>.Create(fConnection, fPersonConfig, fPersonBaseVersionInfoConfig);
  fPersonAddressConfig := TCrudConfigPersonAddress.Create;
  fPersonAddressRecordActions := TRecordActions<TDtoPersonAddress, UInt32>.Create(fConnection, fPersonAddressConfig);
  fAddressConfig := TCrudConfigAddress.Create;
  fClubmembershipConfig := TCrudConfigClubmembership.Create;
  fClubmembershipRecordActions := TRecordActions<TDtoClubmembership, UInt32>.Create(fConnection, fClubmembershipConfig);
  fClubMembershipNumberChecker := TClubMembershipNumberChecker.Create(fConnection);
  fMemberOfConfig := TCrudMemberConfigMasterPerson.Create;

  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  Supports(fUI.GetMemberOfUI, IVersionInfoEntryUI, lVersionInfoEntryUI);
  fPersonMemberOfsVersionInfoAccessor := TPersonMemberOfsVersionInfoAccessor.Create(aConnection, lVersionInfoEntryUI);

  fMemberOfBusiness := TMemberOfBusiness.Create(fConnection, fMemberOfConfig,
    fPersonMemberOfsVersionInfoAccessor, fUI.GetMemberOfUI, fUI.GetProgressIndicator);
end;

destructor TPersonBusiness.Destroy;
begin
  fCurrentEntry.Free;
  fMemberOfBusiness := nil;
  fMemberOfConfig := nil;
  fClubMembershipNumberChecker.Free;
  fClubmembershipRecordActions.Free;
  fClubmembershipConfig := nil;
  fAddressConfig := nil;
  fPersonAddressRecordActions.Free;
  fPersonAddressConfig := nil;
  fPersonRecordActions.Free;
  fPersonConfig := nil;
  fAddressMapper.Free;
  fUI := nil;
  fProgressIndicator := nil;
  fConnection := nil;
  inherited;
end;

function TPersonBusiness.GetAvailableAddresses: TActiveKeyIndexStringsLoader;
begin
  Result := fAddressMapper;
end;

function TPersonBusiness.GetDataChanged: Boolean;
begin
  Result := fDataChanged;
end;

function TPersonBusiness.GetListFilter: TVoid;
begin
  raise ENotImplemented.Create('TPersonBusiness.GetListFilter: TVoid');
end;

function TPersonBusiness.GetShowInactivePersons: Boolean;
begin
  Result := fShowInactivePersons;
end;

function TPersonBusiness.DeleteEntry(const aPersonId: UInt32): TCrudCommandResult;
begin

end;

procedure TPersonBusiness.Initialize;
begin
  fUI.SetPersonBusinessIntf(Self);
  fMemberOfBusiness.Initialize;
end;

function TPersonBusiness.LoadCurrentEntry(const aPersonId: UInt32): TCrudCommandResult;
begin
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, 'Basisdaten werden geladen ...');
  FreeAndNil(fCurrentEntry);
  fNewEntryStarted := False;
  var lRecord := default(TDtoPerson);
  var lResponse := fPersonRecordActions.LoadRecord(aPersonId, lRecord);
  if lResponse.Succeeded then
  begin
    var lPersonAddressRecord := default(TDtoPersonAddress);
    var lExistingAddressId: UInt32 := 0;
    if fPersonAddressRecordActions.LoadRecord(aPersonId, lPersonAddressRecord) then
    begin
      lExistingAddressId := lPersonAddressRecord.AddressId;
    end;
    fCurrentEntry := TDtoPersonAggregated.Create(lRecord, lExistingAddressId, fAddressMapper);
    fCurrentEntry.VersionInfoBaseData.UpdateVersionInfo(lResponse.EntryVersionInfo);
    fCurrentEntry.AddressId := lExistingAddressId;
    var lMembershipRecord := default(TDtoClubmembership);
    if fClubmembershipRecordActions.LoadRecord(fCurrentEntry.Id, lMembershipRecord) then
    begin
      fCurrentEntry.SetDtoClubmembership(lMembershipRecord);
    end;
    SetCurrentEntryToUI(TEntryToUIMode.OnLoadCurrentEntry);
  end
  else
  begin
    ClearEntryFromUI;
    fUI.DeleteEntryFromUI(aPersonId);
  end;
end;

function TPersonBusiness.LoadList: TCrudCommandResult;
begin
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, 'Personen werden geladen ...');
  Result := default(TCrudCommandResult);
  fNewEntryStarted := True;
  ClearEntryFromUI;
  fUI.ListEnumBegin;
  try
    var lSelectList: ISelectList<TDtoPerson>;
    if not Supports(fPersonConfig, ISelectList<TDtoPerson>, lSelectList) then
      raise ENotImplemented.Create('fPersonConfig must implement ISelectList<TDtoPerson>.');
    var lSqlResult :=  fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoPerson);
      fPersonConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      if fShowInactivePersons or lRecord.Active then
      begin
        fUI.ListEnumProcessItem(lRecord);
        fNewEntryStarted := False;
      end;
    end;
  finally
    fUI.ListEnumEnd;
  end;
end;

function TPersonBusiness.LoadPerson(const aPersonId: UInt32; const aLoadMemberOfs: Boolean): TCrudCommandResult;
begin
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, 'Person wird geladen ...');
  LoadCurrentEntry(aPersonId);
  if aLoadMemberOfs then
    LoadPersonsMemberOfs;
end;

procedure TPersonBusiness.LoadPersonsMemberOfs;
begin
  if fNewEntryStarted then
  begin
    fPersonMemberOfsVersionInfoAccessor.SetCurrentPersonEntry(nil);
    fMemberOfBusiness.LoadMemberOfs(0);
  end
  else
  begin
    var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, 'Person wird geladen ...');
    fPersonMemberOfsVersionInfoAccessor.SetCurrentPersonEntry(fCurrentEntry);
    fMemberOfBusiness.LoadMemberOfs(fCurrentEntry.Id);
  end;
end;

function TPersonBusiness.ReloadCurrentEntry: TCrudCommandResult;
begin
  SetCurrentEntryToUI(TEntryToUIMode.OnLoadCurrentEntry);
end;

function TPersonBusiness.SaveCurrentEntry: TCrudSaveResult;
begin
  var lProgress := TProgress.New(fUI.GetProgressIndicator, 0, 'Person wird gespeichert ...');
  Result := default(TCrudSaveResult);
  var lUpdatedEntryCloned := False;
  var lUpdatedEntry: TDtoPersonAggregated := nil;
  try
    if fNewEntryStarted then
      lUpdatedEntry := TDtoPersonAggregated.Create(default(TDtoPerson), 0, fAddressMapper)
    else
      lUpdatedEntry := fCurrentEntry.Clone;
    lUpdatedEntryCloned := True;

    var lSuspendScope := lProgress.SuspendUI;
    try
      var lUIToEntryMode := TUIToEntryMode.OnUpdateEntry;
      if fNewEntryStarted then
        lUIToEntryMode := TUIToEntryMode.OnNewEntry;
      if not fUI.GetEntryFromUI(lUpdatedEntry, lUIToEntryMode, lSuspendScope) then
      begin
        lSuspendScope := nil;
        Exit(TCrudSaveResult.CreateRecord(TCrudSaveStatus.Cancelled));
      end;
    finally
      lSuspendScope := nil;
    end;
    if not lUpdatedEntry.MembershipNoMembership then
    begin
      var lResponse := fClubMembershipNumberChecker.IsMembershipNumberOccupied(lUpdatedEntry.Person.NameId.Id,
        lUpdatedEntry.MembershipNumber);
      if lResponse.NumberIsOccupied then
      begin
        Exit(TCrudSaveResult.CreateCancelledRecord(lResponse.OccupiedToString));
      end;
    end;

    var lReloadAddress := False;
    var lNewPersonCreated := False;
    var lNewAddressCreated := False;
    var lSaveTransaction := fConnection.StartTransaction;
    try
      try
        var lPersonAddressRecord := default(TDtoPersonAddress);
        var lSaveAdressRelation := True;
        var lDeleteAdressRelation := False;
        if lUpdatedEntry.CreateNewAddress then
        begin
          var lNewAddressRecord := default(TDtoAddress);
          lNewAddressRecord.Active := True;
          lNewAddressRecord.Street := lUpdatedEntry.NewAddressStreet;
          lNewAddressRecord.Postalcode := lUpdatedEntry.NewAddressPostalcode;
          lNewAddressRecord.City := lUpdatedEntry.NewAddressCity;
          if not Assigned(fAddressRecordActions) then
          begin
            fAddressRecordActions := TRecordActions<TDtoAddress, UInt32>.Create(fConnection, fAddressConfig);
          end;
          lNewAddressCreated := fAddressRecordActions.SaveRecord(lNewAddressRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created;
          lPersonAddressRecord.AddressId := lNewAddressRecord.Id;
        end
        else
        begin
          lPersonAddressRecord.AddressId := lUpdatedEntry.AddressId;
          lSaveAdressRelation := lUpdatedEntry.ExistingAddressId  <> lUpdatedEntry.AddressId;
          lDeleteAdressRelation := (lUpdatedEntry.ExistingAddressId > 0) and (lUpdatedEntry.AddressId = 0);
        end;

        var lRecord := lUpdatedEntry.Person;
        var lResponse := fPersonRecordActions.SaveRecord(lRecord, lUpdatedEntry.VersionInfoBaseData, lSaveTransaction);
        if lResponse.VersioningState = TVersioningResponseVersioningState.ConflictDetected then
        begin
          if fNewEntryStarted then
            SetVersionInfoEntryToUI(lUpdatedEntry.VersionInfoBaseData)
          else
            fCurrentEntry.VersionInfoBaseData.Assign(lUpdatedEntry.VersionInfoBaseData);
          Exit(TCrudSaveResult.CreateConflictedRecord(lUpdatedEntry.VersionInfoBaseData));
        end;
        if lResponse.Kind = TVersioningSaveKind.Created then
        begin
          lUpdatedEntry.Id := lRecord.NameId.Id;
          lNewPersonCreated := True;
        end;
        lPersonAddressRecord.PersonId := lUpdatedEntry.Id;

        if lDeleteAdressRelation then
        begin
          fPersonAddressRecordActions.DeleteEntry(lPersonAddressRecord.PersonId, lSaveTransaction);
          lUpdatedEntry.AddressId := 0;
          lUpdatedEntry.UpdateExistingAddressId;
        end
        else if lSaveAdressRelation then
        begin
          fPersonAddressRecordActions.SaveRecord(lPersonAddressRecord, lSaveTransaction);
          lUpdatedEntry.UpdateExistingAddressId;
        end;

        var lMembershipRecord := lUpdatedEntry.GetDtoClubmembership;
        if lUpdatedEntry.MembershipNoMembership then
        begin
          if lMembershipRecord.Id > 0 then
          begin
            fClubmembershipRecordActions.DeleteEntry(lMembershipRecord.Id, lSaveTransaction);
          end;
        end
        else
        begin
          if fClubmembershipRecordActions.SaveRecord(lMembershipRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created then
          begin
            lUpdatedEntry.SetDtoClubmembership(lMembershipRecord);
          end;
        end;
        TPersonMapper.Invalidate;
        lSaveTransaction.Commit;
        fCurrentEntry.Free;
        fCurrentEntry := lUpdatedEntry;
        lUpdatedEntryCloned := False;
        fDataChanged := True;
      except
        lSaveTransaction := nil;
        lNewAddressCreated := False;
        lReloadAddress := True;
        Result := TCrudSaveResult.CreateFailedRecord;
        raise;
      end;
    finally
      if lNewAddressCreated then
      begin
        fAddressMapper.Invalidate;
        fUI.LoadCurrentEntry(fCurrentEntry.Id);
      end
      else if lReloadAddress then
      begin
        fUI.LoadCurrentEntry(fCurrentEntry.Id);
      end
      else
      begin
        var lEntryToUI := TEntryToUIMode.OnUpdatedExistingEntry;
        if lNewPersonCreated then
          lEntryToUI := TEntryToUIMode.OnCreatedNewEntry;
        SetCurrentEntryToUI(lEntryToUI);
      end;
    end;
  finally
    if lUpdatedEntryCloned then
      lUpdatedEntry.Free;
    fNewEntryStarted := False;
  end;
end;

procedure TPersonBusiness.SetCurrentEntryToUI(const aMode: TEntryToUIMode);
begin
  fUI.SetEntryToUI(fCurrentEntry, aMode);
  SetVersionInfoEntryToUI(fCurrentEntry.VersionInfoBaseData);
end;

procedure TPersonBusiness.ClearEntryFromUI;
begin
  fUI.ClearEntryFromUI;
  ClearVersionInfoEntryFromUI;
end;

procedure TPersonBusiness.SetVersionInfoEntryToUI(const aVersionInfoEntry: TVersionInfoEntry);
begin
  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
    lVersionInfoEntryUI.SetVersionInfoEntryToUI(aVersionInfoEntry);
end;

procedure TPersonBusiness.ClearVersionInfoEntryFromUI;
begin
  var lVersionInfoEntryUI: IVersionInfoEntryUI;
  if Supports(fUI, IVersionInfoEntryUI, lVersionInfoEntryUI) then
    lVersionInfoEntryUI.ClearVersionInfoEntryFromUI;
end;

procedure TPersonBusiness.SetListFilter(const aValue: TVoid);
begin
  raise ENotImplemented.Create('TPersonBusiness.SetListFilter(const aValue: TVoid)');
end;

procedure TPersonBusiness.SetShowInactivePersons(const aValue: Boolean);
begin
  fShowInactivePersons := aValue;
  LoadList;
end;

procedure TPersonBusiness.StartNewEntry;
begin
  fNewEntryStarted := True;
  ClearEntryFromUI;
end;

procedure TPersonBusiness.ClearAddressCache;
begin
  fAddressMapper.Invalidate;
end;

{ TPersonBasedataVersionInfoConfig }

function TPersonBasedataVersionInfoConfig.GetRecordIdentity(const aRecord: TDtoPerson): UInt32;
begin
  Result := aRecord.NameId.Id;
end;

function TPersonBasedataVersionInfoConfig.GetVersioningEntityId: TEntryVersionInfoEntity;
begin
  Result := TEntryVersionInfoEntity.PersonBaseData;
end;

function TPersonBasedataVersionInfoConfig.GetVersioningIdentityColumnName: string;
begin
  Result := 'person_id'
end;

procedure TPersonBasedataVersionInfoConfig.SetVersionInfoParameter(const aRecordIdentity: UInt32;
  const aParameter: ISqlParameter);
begin
  aParameter.Value := aRecordIdentity;
end;

{ TPersonMemberOfsVersionInfoAccessor }

constructor TPersonMemberOfsVersionInfoAccessor.Create(const aConnection: ISqlConnection; const aUI: IVersionInfoEntryUI);
begin
  inherited Create;
  fUI := aUI;
  fVersionInfoConfig := TMemberOfVersionInfoConfig.Create;
  fVersionInfoAccessor := TVersionInfoAccessor<UInt32, UInt32>.Create(aConnection, fVersionInfoConfig);
end;

destructor TPersonMemberOfsVersionInfoAccessor.Destroy;
begin
  fVersionInfoAccessor.Free;
  fConflictedVersionEntry.Free;
  inherited;
end;

procedure TPersonMemberOfsVersionInfoAccessor.SetCurrentPersonEntry(const aPersonEntry: TDtoPersonAggregated);
begin
  fCurrentPersonEntry := aPersonEntry;
  FreeAndNil(fConflictedVersionEntry);
end;

procedure TPersonMemberOfsVersionInfoAccessor.BeginLoadEntries(const aTransaction: ITransaction);
begin
  var lTransactionScopeLoadEntries := fVersionInfoAccessor.StartTransaction(aTransaction);
  fCurrentPersonEntry.VersionInfoMemberOfs.UpdateVersionInfo(
    fVersionInfoAccessor.QueryVersionInfo(lTransactionScopeLoadEntries, fCurrentPersonEntry.Id));
  fUI.SetVersionInfoEntryToUI(fCurrentPersonEntry.VersionInfoMemberOfs);
end;

procedure TPersonMemberOfsVersionInfoAccessor.LoadEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
end;

procedure TPersonMemberOfsVersionInfoAccessor.EndLoadEntries(const aTransaction: ITransaction);
begin
end;

procedure TPersonMemberOfsVersionInfoAccessor.BeginSaveEntries(const aTransaction: ITransaction);
begin
  fVersionInfoAccessorTransactionScope := fVersionInfoAccessor.StartTransaction(aTransaction);
  if fVersionInfoAccessor.UpdateVersionInfo(fVersionInfoAccessorTransactionScope, fCurrentPersonEntry.Id,
    fCurrentPersonEntry.VersionInfoMemberOfs) then
  begin
    FreeAndNil(fConflictedVersionEntry);
  end
  else
  begin
    fVersionInfoAccessorTransactionScope.RollbackOnVersionConflict;
    if not Assigned(fConflictedVersionEntry) then
      fConflictedVersionEntry := TVersionInfoEntry.Create;
    fConflictedVersionEntry.Assign(fCurrentPersonEntry.VersionInfoMemberOfs);
  end;
  fUI.SetVersionInfoEntryToUI(fCurrentPersonEntry.VersionInfoMemberOfs);
end;

procedure TPersonMemberOfsVersionInfoAccessor.SaveEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
end;

procedure TPersonMemberOfsVersionInfoAccessor.DeleteEntry(const aEntry: TDtoMemberAggregated;
  const aTransaction: ITransaction);
begin
end;

procedure TPersonMemberOfsVersionInfoAccessor.EndSaveEntries(const aTransaction: ITransaction);
begin
  fVersionInfoAccessorTransactionScope := nil;
end;

function TPersonMemberOfsVersionInfoAccessor.GetConflictedVersionEntry: TVersionInfoEntry;
begin
  Result := fConflictedVersionEntry;
end;

function TPersonMemberOfsVersionInfoAccessor.GetVersionConflictDetected: Boolean;
begin
  Result := Assigned(fConflictedVersionEntry);
end;

end.
