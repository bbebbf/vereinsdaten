unit MainBusiness;

interface

uses System.Classes, System.SysUtils, CrudCommands, CrudConfig, Transaction, MainBusinessIntf,
  DtoPersonAggregated, SqlConnection, PersonAggregatedUI, DtoPerson, RecordActions,
  KeyIndexMapper, DtoPersonAddress, DtoAddress, DtoClubmembership;

type
  TMainBusiness = class(TInterfacedObject, IMainBusinessIntf)
  strict private
    fConnection: ISqlConnection;
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

    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
    function SaveCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
    function ReloadCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
    function DeleteRecord(const aPersonId: Int32): TCrudCommandResult;
    procedure LoadAvailableAddresses(const aStrings: TStrings);
    function GetShowInactivePersons: Boolean;
    procedure SetShowInactivePersons(const aValue: Boolean);

    procedure CheckCurrentPersonId(const aPersonId: Int32);
  public
    constructor Create(aConnection: ISqlConnection; aUI: IPersonAggregatedUI);
    destructor Destroy; override;
  end;

implementation

uses System.Generics.Collections, DefaultCrudCommands,
  CrudConfigPerson, CrudConfigAddress, CrudConfigPersonAddress, CrudConfigClubmembership;

{ TMainBusiness }

constructor TMainBusiness.Create(aConnection: ISqlConnection; aUI: IPersonAggregatedUI);
begin
  inherited Create;
  fConnection := aConnection;
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
end;

destructor TMainBusiness.Destroy;
begin
  fCurrentRecord.Free;
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
  fCurrentRecord.Free;
  var lRecord := default(TDtoPerson);
  if fPersonRecordActions.LoadRecord(aPersonId, lRecord) then
  begin
    fCurrentRecord := TDtoPersonAggregated.Create(lRecord);
    var lPersonAddressRecord := default(TDtoPersonAddress);
    if fPersonAddressRecordActions.LoadRecord(fCurrentRecord.Id, lPersonAddressRecord) then
    begin
      fCurrentRecord.AddressIndex := fAddressMapper.GetIndex(lPersonAddressRecord.AddressId);
    end;
    var lMembershipRecord := default(TDtoClubmembership);
    if fClubmembershipRecordActions.LoadRecord(fCurrentRecord.Id, lMembershipRecord) then
    begin
      fCurrentRecord.SetDtoClubmembership(lMembershipRecord);
    end;
    fUI.SetRecordToUI(fCurrentRecord);
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
  fUI.SetRecordToUI(fCurrentRecord);
end;

function TMainBusiness.SaveCurrentRecord(const aPersonId: Int32): TCrudCommandResult;
begin
  CheckCurrentPersonId(aPersonId);
  fUI.GetRecordFromUI(fCurrentRecord);

  var lPersonAddressRecord := default(TDtoPersonAddress);
  var lDeleteAdressRelation := False;
  var lNewAddressCreated := False;
  if fCurrentRecord.CreateNewAddress then
  begin
    var lNewAddressRecord := default(TDtoAddress);
    lNewAddressRecord.Street := fCurrentRecord.NewAddressStreet;
    lNewAddressRecord.Postalcode := fCurrentRecord.NewAddressPostalcode;
    lNewAddressRecord.City := fCurrentRecord.NewAddressCity;
    lNewAddressCreated := fAddressRecordActions.SaveRecord(lNewAddressRecord) = TRecordActionsSaveResponse.Created;
    lPersonAddressRecord.AddressId := lNewAddressRecord.Id;
  end
  else
  begin
    lPersonAddressRecord.AddressId := fAddressMapper.GetKey(fCurrentRecord.AddressIndex);
    lDeleteAdressRelation := lPersonAddressRecord.AddressId = 0;
  end;

  var lRecord := fCurrentRecord.Person;
  if fPersonRecordActions.SaveRecord(lRecord) = TRecordActionsSaveResponse.Created then
  begin
    fCurrentRecord.Id := lRecord.Id;
  end;
  lPersonAddressRecord.PersonId := fCurrentRecord.Id;

  if lDeleteAdressRelation then
  begin
    fPersonAddressRecordActions.DeleteRecord(lPersonAddressRecord.PersonId);
    fCurrentRecord.AddressIndex := -1;
  end
  else
  begin
    fPersonAddressRecordActions.SaveRecord(lPersonAddressRecord);
  end;

  var lMembershipRecord := fCurrentRecord.GetDtoClubmembership;
  if fCurrentRecord.MembershipNoMembership then
  begin
    if lMembershipRecord.Id > 0 then
    begin
      fClubmembershipRecordActions.DeleteRecord(lMembershipRecord.Id);
    end;
  end
  else
  begin
    if fClubmembershipRecordActions.SaveRecord(lMembershipRecord) = TRecordActionsSaveResponse.Created then
    begin
      fCurrentRecord.SetDtoClubmembership(lMembershipRecord);
    end;
  end;

  if lNewAddressCreated then
  begin
    fUI.LoadAvailableAdresses;
    fUI.LoadCurrentRecord(fCurrentRecord.Id);
  end
  else
  begin
    fUI.SetRecordToUI(fCurrentRecord);
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
    raise Exception.Create('Current record person id ' + IntToStr(fCurrentRecord.Person.Id) + ' found but ' +
      IntToStr(aPersonId) + ' expected.');
end;

end.
