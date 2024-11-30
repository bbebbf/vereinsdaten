unit MainBusiness;

interface

uses System.Classes, System.SysUtils, CrudCommands, CrudConfig, Transaction, MainBusinessIntf,
  DtoPersonAggregated, SqlConnection, PersonAggregatedUI, DtoPerson, RecordActions,
  KeyIndexMapper, DtoPersonAddress, DtoAddress, DtoClubmembership, ProgressObserver, ClubmembershipTools;

type
  TMainBusiness = class(TInterfacedObject, IMainBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fProgressObserver: IProgressObserver;
    fPersonConfig: ICrudConfig<TDtoPerson, Int32>;
    fPersonRecordActions: TRecordActions<TDtoPerson, Int32>;
    fPersonAddressConfig: ICrudConfig<TDtoPersonAddress, Int32>;
    fPersonAddressRecordActions: TRecordActions<TDtoPersonAddress, Int32>;
    fAddressConfig: ICrudConfig<TDtoAddress, Int32>;
    fAddressRecordActions: TRecordActions<TDtoAddress, Int32>;
    fClubmembershipConfig: ICrudConfig<TDtoClubmembership, Int32>;
    fClubmembershipRecordActions: TRecordActions<TDtoClubmembership, Int32>;
    fUI: IPersonAggregatedUI;
    fCurrentRecord: TDtoPersonAggregated;
    fAddressMapper: TKeyIndexMapper<Int32>;
    fShowInactivePersons: Boolean;
    fClubMembershipNumberChecker: TClubMembershipNumberChecker;

    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
    function SaveCurrentRecord(const aPersonId: Int32): TCrudSaveRecordResult;
    function ReloadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
    function DeleteRecord(const aPersonId: Int32): TCrudCommandResult;
    procedure LoadAvailableAddresses(const aStrings: TStrings);
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);

    procedure CheckCurrentPersonId(const aPersonId: Int32);
  public
    constructor Create(aConnection: ISqlConnection; aUI: IPersonAggregatedUI;
      aProgressObserver: IProgressObserver);
    destructor Destroy; override;
  end;

implementation

uses System.Generics.Collections, DefaultCrudCommands,
  CrudConfigPerson, CrudConfigAddress, CrudConfigPersonAddress, CrudConfigClubmembership;

{ TMainBusiness }

constructor TMainBusiness.Create(aConnection: ISqlConnection; aUI: IPersonAggregatedUI;
  aProgressObserver: IProgressObserver);
begin
  inherited Create;
  fConnection := aConnection;
  fProgressObserver := aProgressObserver;
  fUI := aUI;
  fAddressMapper := TKeyIndexMapper<Int32>.Create(0);
  fPersonConfig := TCrudConfigPerson.Create;
  fPersonRecordActions := TRecordActions<TDtoPerson, Int32>.Create(fConnection, fPersonConfig);
  fPersonAddressConfig := TCrudConfigPersonAddress.Create;
  fPersonAddressRecordActions := TRecordActions<TDtoPersonAddress, Int32>.Create(fConnection, fPersonAddressConfig);
  fAddressConfig := TCrudConfigAddress.Create;
  fAddressRecordActions := TRecordActions<TDtoAddress, Int32>.Create(fConnection, fAddressConfig);
  fClubmembershipConfig := TCrudConfigClubmembership.Create;
  fClubmembershipRecordActions := TRecordActions<TDtoClubmembership, Int32>.Create(fConnection, fClubmembershipConfig);
  fClubMembershipNumberChecker := TClubMembershipNumberChecker.Create(fConnection);
end;

destructor TMainBusiness.Destroy;
begin
  fCurrentRecord.Free;
  fClubMembershipNumberChecker.Free;
  fClubmembershipRecordActions.Free;
  fPersonAddressRecordActions.Free;
  fPersonRecordActions.Free;
  fAddressMapper.Free;
  inherited;
end;

function TMainBusiness.GetShowInactivePersons: Boolean;
begin
  Result := fShowInactivePersons;
end;

function TMainBusiness.DeleteRecord(const aPersonId: Int32): TCrudCommandResult;
begin

end;

procedure TMainBusiness.Initialize;
begin
  fUI.Initialize(Self);
end;

procedure TMainBusiness.LoadAvailableAddresses(const aStrings: TStrings);
begin
  aStrings.BeginUpdate;
  try
    fAddressMapper.Clear;
    aStrings.Clear;
    aStrings.Add('<Adresse auswählen>');
    var lSqlResult := fConnection.GetSelectResult(fAddressConfig.GetSelectSqlList);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoAddress);
      fAddressConfig.SetRecordFromResult(lSqlResult, lRecord);
      fAddressMapper.Add(lRecord.Id, aStrings.Add(lRecord.ToString));
    end;
  finally
    aStrings.EndUpdate;
  end;
end;

function TMainBusiness.LoadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
begin
  FreeAndNil(fCurrentRecord);
  var lRecord := default(TDtoPerson);
  if fPersonRecordActions.LoadRecord(aPersonId, lRecord) then
  begin
    fCurrentRecord := TDtoPersonAggregated.Create(lRecord);
    var lPersonAddressRecord := default(TDtoPersonAddress);
    if fPersonAddressRecordActions.LoadRecord(fCurrentRecord.Id, lPersonAddressRecord) then
    begin
      fCurrentRecord.ExistingAddressId := lPersonAddressRecord.AddressId;
      fCurrentRecord.AddressIndex := fAddressMapper.GetIndex(lPersonAddressRecord.AddressId);
    end;
    var lMembershipRecord := default(TDtoClubmembership);
    if fClubmembershipRecordActions.LoadRecord(fCurrentRecord.Id, lMembershipRecord) then
    begin
      fCurrentRecord.SetDtoClubmembership(lMembershipRecord);
    end;
    fUI.SetRecordToUI(fCurrentRecord, False);
  end
  else
  begin
    fUI.ClearRecordUI;
    fUI.DeleteRecordfromUI(aPersonId);
  end;
end;

function TMainBusiness.LoadList: TCrudCommandResult;
begin
  Result := default(TCrudCommandResult);
  fUI.LoadUIListBegin;
  try
    var lSqlResult := fConnection.GetSelectResult(fPersonConfig.GetSelectSqlList);
    while lSqlResult.Next do
    begin
      var lRecord := default(TDtoPerson);
      fPersonConfig.SetRecordFromResult(lSqlResult, lRecord);
      if fShowInactivePersons or lRecord.Aktiv then
        fUI.LoadUIListAddRecord(TDtoPersonAggregated.Create(lRecord));
    end;
  finally
    fUI.LoadUIListEnd;
  end;
end;

function TMainBusiness.ReloadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
begin
  CheckCurrentPersonId(aPersonId);
  fUI.SetRecordToUI(fCurrentRecord, False);
end;

function TMainBusiness.SaveCurrentRecord(const aPersonId: Int32): TCrudSaveRecordResult;
begin
  Result := default(TCrudSaveRecordResult);
  var lNewRecord: TDtoPersonAggregated := nil;
  try
    if aPersonId = 0 then
      lNewRecord := TDtoPersonAggregated.Create(default(TDtoPerson))
    else
      lNewRecord := fCurrentRecord.Clone;

    if not fUI.GetRecordFromUI(lNewRecord) then
    begin
      Exit(TCrudSaveRecordResult.CreateRecord(TCrudSaveRecordStatus.Cancelled));
    end;
    if not lNewRecord.MembershipNoMembership then
    begin
      var lResponse := fClubMembershipNumberChecker.IsMembershipNumberOccupied(lNewRecord.Person.Id,
        lNewRecord.MembershipNumber);
      if lResponse.NumberIsOccupied then
      begin
        Exit(TCrudSaveRecordResult.CreateCancelledRecord(lResponse.OccupiedToString));
      end;
    end;

    if aPersonId > 0 then
      CheckCurrentPersonId(aPersonId);

    var lReloadAddress := False;
    var lNewPersonCreated := False;
    var lNewAddressCreated := False;
    var lSaveTransaction := fConnection.StartTransaction;
    try
      try
        var lPersonAddressRecord := default(TDtoPersonAddress);
        var lDeleteAdressRelation := False;
        if lNewRecord.CreateNewAddress then
        begin
          var lNewAddressRecord := default(TDtoAddress);
          lNewAddressRecord.Street := lNewRecord.NewAddressStreet;
          lNewAddressRecord.Postalcode := lNewRecord.NewAddressPostalcode;
          lNewAddressRecord.City := lNewRecord.NewAddressCity;
          lNewAddressCreated := fAddressRecordActions.SaveRecord(lNewAddressRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created;
          lPersonAddressRecord.AddressId := lNewAddressRecord.Id;
        end
        else
        begin
          lPersonAddressRecord.AddressId := fAddressMapper.GetKey(lNewRecord.AddressIndex);
          lDeleteAdressRelation := (lNewRecord.ExistingAddressId > 0) and (lPersonAddressRecord.AddressId = 0);
        end;

        var lRecord := lNewRecord.Person;
        if fPersonRecordActions.SaveRecord(lRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created then
        begin
          lNewRecord.Id := lRecord.Id;
          lNewPersonCreated := True;
        end;
        lPersonAddressRecord.PersonId := lNewRecord.Id;

        if lDeleteAdressRelation then
        begin
          fPersonAddressRecordActions.DeleteRecord(lPersonAddressRecord.PersonId, lSaveTransaction);
          lNewRecord.AddressIndex := -1;
        end
        else if lPersonAddressRecord.AddressId > 0 then
        begin
          fPersonAddressRecordActions.SaveRecord(lPersonAddressRecord, lSaveTransaction);
        end;

        var lMembershipRecord := lNewRecord.GetDtoClubmembership;
        if lNewRecord.MembershipNoMembership then
        begin
          if lMembershipRecord.Id > 0 then
          begin
            fClubmembershipRecordActions.DeleteRecord(lMembershipRecord.Id, lSaveTransaction);
          end;
        end
        else
        begin
          if fClubmembershipRecordActions.SaveRecord(lMembershipRecord, lSaveTransaction) = TRecordActionsSaveResponse.Created then
          begin
            lNewRecord.SetDtoClubmembership(lMembershipRecord);
          end;
        end;
        lSaveTransaction.Commit;
        fCurrentRecord.Free;
        fCurrentRecord := lNewRecord.Clone;
      except
        lSaveTransaction := nil;
        lNewAddressCreated := False;
        lReloadAddress := True;
        Result := TCrudSaveRecordResult.CreateFailedRecord;
        raise;
      end;
    finally
      if lNewAddressCreated then
      begin
        fUI.LoadAvailableAdresses;
        fUI.LoadCurrentRecord(lNewRecord.Id);
      end
      else if lReloadAddress then
      begin
        fUI.LoadCurrentRecord(lNewRecord.Id);
      end
      else
      begin
        fUI.SetRecordToUI(lNewRecord, lNewPersonCreated);
      end;
    end;
  finally
    lNewRecord.Free;
  end;
end;

procedure TMainBusiness.SetShowInactivePersons(const aValue: Boolean);
begin
  fShowInactivePersons := aValue;
  LoadList;
end;

procedure TMainBusiness.CheckCurrentPersonId(const aPersonId: Int32);
begin
  if not Assigned(fCurrentRecord) then
    raise Exception.Create('No current record.');
  if fCurrentRecord.Person.Id <> aPersonId then
    raise Exception.Create('Current record person id is ' + IntToStr(fCurrentRecord.Person.Id) + ' but ' +
      IntToStr(aPersonId) + ' is coming in.');
end;

end.
