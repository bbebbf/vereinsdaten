unit PersonBusiness;

interface

uses System.Classes, InterfacedBase, CrudCommands, CrudConfig, Transaction, PersonBusinessIntf,
  DtoPersonAggregated, SqlConnection, PersonAggregatedUI, DtoPerson, RecordActions,
  KeyIndexMapper, DtoPersonAddress, DtoAddress, DtoClubmembership, ClubmembershipTools,
  MemberOfBusinessIntf, ProgressIndicator;

type
  TPersonBusiness = class(TInterfacedBase, IPersonBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fProgressIndicator: IProgressIndicator;
    fPersonConfig: ICrudConfig<TDtoPerson, UInt32>;
    fPersonRecordActions: TRecordActions<TDtoPerson, UInt32>;
    fPersonAddressConfig: ICrudConfig<TDtoPersonAddress, UInt32>;
    fPersonAddressRecordActions: TRecordActions<TDtoPersonAddress, UInt32>;
    fAddressConfig: ICrudConfig<TDtoAddress, UInt32>;
    fAddressRecordActions: TRecordActions<TDtoAddress, UInt32>;
    fClubmembershipConfig: ICrudConfig<TDtoClubmembership, UInt32>;
    fClubmembershipRecordActions: TRecordActions<TDtoClubmembership, UInt32>;
    fUI: IPersonAggregatedUI;
    fCurrentEntry: TDtoPersonAggregated;
    fNewEntryStarted: Boolean;
    fAddressMapper: TKeyIndexMapper<UInt32>;
    fShowInactivePersons: Boolean;
    fClubMembershipNumberChecker: TClubMembershipNumberChecker;
    fMemberOfBusiness: IMemberOfBusinessIntf;
    fDataChanged: Boolean;

    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentEntry(const aPersonId: UInt32): TCrudCommandResult;
    function SaveCurrentEntry: TCrudSaveResult;
    function ReloadCurrentEntry: TCrudCommandResult;
    procedure StartNewEntry;
    function DeleteEntry(const aPersonId: UInt32): TCrudCommandResult;
    function GetDataChanged: Boolean;
    procedure LoadAvailableAddresses(const aStrings: TStrings);
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);
    procedure LoadPersonsMemberOfs;
    procedure ClearUnitCache;
    procedure ClearRoleCache;
  public
    constructor Create(const aConnection: ISqlConnection; const aUI: IPersonAggregatedUI;
      const aProgressIndicator: IProgressIndicator);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, System.Generics.Collections, SelectList,
  CrudConfigPerson, CrudConfigAddress, CrudConfigPersonAddress, CrudConfigClubmembership,
  MemberOfBusiness, EntryCrudConfig, CrudConfigUnitAggregated, CrudBusiness;

{ TPersonBusiness }

constructor TPersonBusiness.Create(const aConnection: ISqlConnection; const aUI: IPersonAggregatedUI;
  const aProgressIndicator: IProgressIndicator);
begin
  inherited Create;
  fConnection := aConnection;
  fProgressIndicator := aProgressIndicator;
  fUI := aUI;
  fAddressMapper := TKeyIndexMapper<UInt32>.Create(0);
  fPersonConfig := TCrudConfigPerson.Create;
  fPersonRecordActions := TRecordActions<TDtoPerson, UInt32>.Create(fConnection, fPersonConfig);
  fPersonAddressConfig := TCrudConfigPersonAddress.Create;
  fPersonAddressRecordActions := TRecordActions<TDtoPersonAddress, UInt32>.Create(fConnection, fPersonAddressConfig);
  fAddressConfig := TCrudConfigAddress.Create;
  fClubmembershipConfig := TCrudConfigClubmembership.Create;
  fClubmembershipRecordActions := TRecordActions<TDtoClubmembership, UInt32>.Create(fConnection, fClubmembershipConfig);
  fClubMembershipNumberChecker := TClubMembershipNumberChecker.Create(fConnection);
  fMemberOfBusiness := TMemberOfBusiness.Create(fConnection, fUI.GetMemberOfUI);
end;

destructor TPersonBusiness.Destroy;
begin
  fCurrentEntry.Free;
  fMemberOfBusiness := nil;
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

function TPersonBusiness.GetDataChanged: Boolean;
begin
  Result := fDataChanged;
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

procedure TPersonBusiness.LoadAvailableAddresses(const aStrings: TStrings);
begin
  aStrings.BeginUpdate;
  try
    fAddressMapper.Clear;
    aStrings.Clear;
    aStrings.Add('<Adresse auswählen>');
    var lSelectList: ISelectList<TDtoAddress>;
    var lSqlResult: ISqlResult := nil;
    if not Supports(fAddressConfig, ISelectList<TDtoAddress>, lSelectList) then
      raise ENotImplemented.Create('fAddressConfig must implement ISelectList<TDtoPerson>.');
    lSqlResult :=  fConnection.GetSelectResult(lSelectList.GetSelectListSQL);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoAddress);
      fAddressConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
      fAddressMapper.Add(lRecord.Id, aStrings.Add(lRecord.ToString));
    end;
  finally
    aStrings.EndUpdate;
  end;
end;

function TPersonBusiness.LoadCurrentEntry(const aPersonId: UInt32): TCrudCommandResult;
begin
  FreeAndNil(fCurrentEntry);
  fNewEntryStarted := False;
  var lRecord := default(TDtoPerson);
  if fPersonRecordActions.LoadRecord(aPersonId, lRecord) then
  begin
    fCurrentEntry := TDtoPersonAggregated.Create(lRecord);
    var lPersonAddressRecord := default(TDtoPersonAddress);
    if fPersonAddressRecordActions.LoadRecord(fCurrentEntry.Id, lPersonAddressRecord) then
    begin
      fCurrentEntry.ExistingAddressId := lPersonAddressRecord.AddressId;
      fCurrentEntry.AddressIndex := fAddressMapper.GetIndex(lPersonAddressRecord.AddressId);
    end;
    var lMembershipRecord := default(TDtoClubmembership);
    if fClubmembershipRecordActions.LoadRecord(fCurrentEntry.Id, lMembershipRecord) then
    begin
      fCurrentEntry.SetDtoClubmembership(lMembershipRecord);
    end;
    fUI.SetEntryToUI(fCurrentEntry, False);
  end
  else
  begin
    fUI.ClearEntryFromUI;
    fUI.DeleteEntryFromUI(aPersonId);
  end;
end;

function TPersonBusiness.LoadList: TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fNewEntryStarted := False;
  fUI.ClearEntryFromUI;
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
      if fShowInactivePersons or lRecord.Aktiv then
      begin
        fUI.ListEnumProcessItem(lRecord);
      end;
    end;
  finally
    fUI.ListEnumEnd;
  end;
end;

procedure TPersonBusiness.LoadPersonsMemberOfs;
begin
  var lPersonId: UInt32 := 0;
  if not fNewEntryStarted then
    lPersonId := fCurrentEntry.Id;
  fMemberOfBusiness.LoadPersonsMemberOfs(lPersonId);
end;

function TPersonBusiness.ReloadCurrentEntry: TCrudCommandResult;
begin
  fUI.SetEntryToUI(fCurrentEntry, False);
end;

function TPersonBusiness.SaveCurrentEntry: TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  var lUpdatedEntryCloned := False;
  var lUpdatedEntry: TDtoPersonAggregated := nil;
  try
    if fNewEntryStarted then
      lUpdatedEntry := TDtoPersonAggregated.Create(default(TDtoPerson))
    else
      lUpdatedEntry := fCurrentEntry.Clone;
    lUpdatedEntryCloned := True;

    if not fUI.GetEntryFromUI(lUpdatedEntry) then
    begin
      Exit(TCrudSaveResult.CreateRecord(TCrudSaveStatus.Cancelled));
    end;
    if not lUpdatedEntry.MembershipNoMembership then
    begin
      var lResponse := fClubMembershipNumberChecker.IsMembershipNumberOccupied(lUpdatedEntry.Person.Id,
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
        var lDeleteAdressRelation := False;
        if lUpdatedEntry.CreateNewAddress then
        begin
          var lNewAddressRecord := default(TDtoAddress);
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
          lPersonAddressRecord.AddressId := fAddressMapper.GetKey(lUpdatedEntry.AddressIndex);
          lDeleteAdressRelation := (lUpdatedEntry.ExistingAddressId > 0) and (lPersonAddressRecord.AddressId = 0);
        end;

        var lRecord := lUpdatedEntry.Person;
        if fPersonRecordActions.SaveRecord(lRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created then
        begin
          lUpdatedEntry.Id := lRecord.Id;
          lNewPersonCreated := True;
        end;
        lPersonAddressRecord.PersonId := lUpdatedEntry.Id;

        if lDeleteAdressRelation then
        begin
          fPersonAddressRecordActions.DeleteEntry(lPersonAddressRecord.PersonId, lSaveTransaction);
          lUpdatedEntry.AddressIndex := -1;
        end
        else if lPersonAddressRecord.AddressId > 0 then
        begin
          fPersonAddressRecordActions.SaveRecord(lPersonAddressRecord, lSaveTransaction);
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
        fUI.LoadAvailableAdresses;
        fUI.LoadCurrentEntry(fCurrentEntry.Id);
      end
      else if lReloadAddress then
      begin
        fUI.LoadCurrentEntry(fCurrentEntry.Id);
      end
      else
      begin
        fUI.SetEntryToUI(fCurrentEntry, lNewPersonCreated);
      end;
    end;
  finally
    if lUpdatedEntryCloned then
      lUpdatedEntry.Free;
    fNewEntryStarted := False;
  end;
end;

procedure TPersonBusiness.SetShowInactivePersons(const aValue: Boolean);
begin
  fShowInactivePersons := aValue;
  LoadList;
end;

procedure TPersonBusiness.StartNewEntry;
begin
  fNewEntryStarted := True;
  fUI.ClearEntryFromUI;
end;

procedure TPersonBusiness.ClearRoleCache;
begin
  fMemberOfBusiness.ClearRoleCache;
end;

procedure TPersonBusiness.ClearUnitCache;
begin
  fMemberOfBusiness.ClearUnitCache;
end;

end.
