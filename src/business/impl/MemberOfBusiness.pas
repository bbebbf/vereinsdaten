unit MemberOfBusiness;

interface

uses System.Classes, System.Generics.Collections, InterfacedBase, SqlConnection, MemberOfBusinessIntf,
  PersonMemberOfUI, KeyIndexStrings, CrudConfig,
  DtoMemberAggregated, DtoMember, DtoUnit, DtoRole, ListCrudCommands, SelectList, SelectListFilter,
  ValueConverter;

type
  TMemberOfBusinessRecordFilter = record
    ShowInactiveMemberOfs: Boolean;
  end;

  TMemberOfBusiness = class(TInterfacedBase, IMemberOfBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fUI: IPersonMemberOfUI;
    fMemberConfig: ICrudConfig<TDtoMember, UInt32>;
    fListCrudCommands: TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated, UInt32, TMemberOfBusinessRecordFilter>;
    fUnitMapper: TKeyIndexStrings;
    fUnitListConfig: ISelectList<TDtoUnit>;
    fRoleMapper: TKeyIndexStrings;
    fRoleListConfig: ISelectList<TDtoRole>;
    fCurrentPersonId: UInt32;
    fCurrentFilter: TMemberOfBusinessRecordFilter;
    fSelectListFilter: ISelectListFilter<TDtoMember, UInt32>;
    fValueConverter: IValueConverter<TDtoMember, TDtoMemberAggregated>;
    procedure Initialize;
    procedure LoadPersonsMemberOfs(const aPersonId: UInt32);
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
  public
    constructor Create(const aConnection: ISqlConnection; const aUI: IPersonMemberOfUI);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, CrudMemberConfig, CrudConfigUnit, CrudConfigRole, KeyIndexMapper;

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

{ TMemberOfBusiness }

constructor TMemberOfBusiness.Create(const aConnection: ISqlConnection; const aUI: IPersonMemberOfUI);
begin
  inherited Create;
  fConnection := aConnection;
  fUI := aUI;
  fMemberConfig := TCrudMemberConfig.Create;

  if not Supports(fMemberConfig, ISelectListFilter<TDtoMember, UInt32>, fSelectListFilter) then
    raise ENotSupportedException.Create('aCrudConfig doesn''t support ISelectListFilter.');

  fUnitListConfig := TCrudConfigUnit.Create;
  fRoleListConfig := TCrudConfigRole.Create;
  fUnitMapper := TKeyIndexStrings.Create(
      function(var aData: TKeyIndexStringsMapperRecord): Boolean
      begin
        Result := True;
        aData.Mapper := TKeyIndexMapper<UInt32>.Create(0);
        aData.Strings := TStringList.Create;
        try
          aData.Strings.BeginUpdate;
          aData.Strings.Add('<Einheit auswählen>');
          var lSqlResult := fConnection.GetSelectResult(fUnitListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoUnit);
            fUnitListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.Mapper.Add(lRecord.Id, aData.Strings.Add(lRecord.ToString));
          end;
        finally
          aData.Strings.EndUpdate;
        end;
      end
    );
  fRoleMapper := TKeyIndexStrings.Create(
      function(var aData: TKeyIndexStringsMapperRecord): Boolean
      begin
        Result := True;
        aData.Mapper := TKeyIndexMapper<UInt32>.Create(0);
        aData.Strings := TStringList.Create;
        try
          aData.Strings.BeginUpdate;
          aData.Strings.Add('<Rolle auswählen>');
          var lSqlResult := fConnection.GetSelectResult(fRoleListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoRole);
            fRoleListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.Mapper.Add(lRecord.Id, aData.Strings.Add(lRecord.ToString));
          end;
        finally
          aData.Strings.EndUpdate;
        end;
      end
    );

  fValueConverter := TDtoMemberConverter.Create(fUnitMapper, fRoleMapper);
  fListCrudCommands := TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated,
    UInt32, TMemberOfBusinessRecordFilter>.Create(
    fConnection, fSelectListFilter, fMemberConfig, fValueConverter);
  fListCrudCommands.TargetEnumerator := fUI;
  fListCrudCommands.OnItemMatchesFilter := OnItemMatchesFilter;
end;

destructor TMemberOfBusiness.Destroy;
begin
  fListCrudCommands.Free;
  fRoleMapper.Free;
  fUnitMapper.Free;
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
  aEntry.Data.PersonId := fCurrentPersonId;
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

procedure TMemberOfBusiness.UpdateFilter;
begin
  fListCrudCommands.BeginUpdateFilter;
  fListCrudCommands.FilterSelect := fCurrentPersonId;
  fListCrudCommands.FilterLoop := fCurrentFilter;
  fListCrudCommands.EndUpdateFilter;
end;

procedure TMemberOfBusiness.LoadPersonsMemberOfs(const aPersonId: UInt32);
begin
  if fCurrentPersonId = aPersonId then
    Exit;

  fCurrentPersonId := aPersonId;
  UpdateFilter;
end;

procedure TMemberOfBusiness.OnItemMatchesFilter(Sender: TObject; const aItem: TDtoMember;
  const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
begin
  aItemMatches := aItem.Active or aFilter.ShowInactiveMemberOfs;
end;

procedure TMemberOfBusiness.SaveEntries(
  const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>);
begin
  fListCrudCommands.SaveChanges(aDeleteEntryCallback);
end;

procedure TMemberOfBusiness.ReloadEntries;
begin
  fListCrudCommands.Reload;
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

end.
