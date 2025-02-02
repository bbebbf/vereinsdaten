﻿unit MemberOfBusiness;

interface

uses System.Classes, System.Generics.Collections, InterfacedBase, SqlConnection, MemberOfBusinessIntf,
  MemberOfConfigIntf, MemberOfUI, KeyIndexStrings, CrudConfig, FilterSelect, Transaction,
  DtoMemberAggregated, DtoMember, DtoRole, ListCrudCommands, SelectList, SelectListFilter,
  ValueConverter, Vdm.Types, Vdm.Versioning.Types, CrudCommands, EntriesCrudEvents;

type
  TMemberOfBusinessRecordFilter = record
    ShowInactiveMemberOfs: Boolean;
  end;

  TMemberOfBusiness = class(TInterfacedBase, IMemberOfBusinessIntf)
  strict private
    fConnection: ISqlConnection;
    fUI: IMemberOfUI;
    fMemberOfConfig: IMemberOfConfigIntf;
    fListCrudCommands: TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated, UInt32, TMemberOfBusinessRecordFilter>;
    fRoleMapper: TKeyIndexStrings;
    fRoleListConfig: ISelectList<TDtoRole>;
    fCurrentMasterId: UInt32;
    fCurrentFilter: TMemberOfBusinessRecordFilter;
    fSelectListFilter: ISelectListFilter<TDtoMember, UInt32>;
    fValueConverter: IValueConverter<TDtoMember, TDtoMemberAggregated>;
    fMemberOfsVersioningCrudEvents: IMemberOfsVersioningCrudEvents;
    procedure Initialize;
    procedure LoadMemberOfs(const aMasterId: UInt32);
    function GetShowInactiveMemberOfs: Boolean;
    procedure SetShowInactiveMemberOfs(const aValue: Boolean);
    function CreateNewEntry: TListEntry<TDtoMemberAggregated>;
    procedure AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
    procedure ReloadEntries;
    function SaveEntries(const aDeleteEntryFromUICallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>):
      TCrudSaveResult;
    procedure ClearDetailItemCache;
    procedure ClearRoleCache;

    procedure UpdateFilter;
    procedure OnItemMatchesFilter(Sender: TObject;
      const aItem: TDtoMember; const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
    function GetDetailItemTitle: string;
    function GetShowVersionInfoInMemberListview: Boolean;
  public
    constructor Create(const aConnection: ISqlConnection; const aMemberOfConfig: IMemberOfConfigIntf;
      const aMemberOfsVersioningCrudEvents: IMemberOfsVersioningCrudEvents; const aUI: IMemberOfUI);
    destructor Destroy; override;
  end;

implementation

uses System.SysUtils, CrudConfigRole, KeyIndexMapper;

type
  TDtoMemberConverter = class(TInterfacedBase, IValueConverter<TDtoMember, TDtoMemberAggregated>)
  strict private
    fMemberOfConfig: IMemberOfConfigIntf;
    fRoleMapper: TKeyIndexStrings;
    procedure Convert(const aValue: TDtoMember; var aTarget: TDtoMemberAggregated);
    procedure ConvertBack(const aValue: TDtoMemberAggregated; var aTarget: TDtoMember);
  public
    constructor Create(const aMemberOfConfig: IMemberOfConfigIntf; const aRoleMapper: TKeyIndexStrings);
  end;

{ TMemberOfBusiness }

constructor TMemberOfBusiness.Create(const aConnection: ISqlConnection; const aMemberOfConfig: IMemberOfConfigIntf;
  const aMemberOfsVersioningCrudEvents: IMemberOfsVersioningCrudEvents; const aUI: IMemberOfUI);
begin
  inherited Create;
  fConnection := aConnection;
  fUI := aUI;
  fMemberOfConfig := aMemberOfConfig;
  fMemberOfsVersioningCrudEvents := aMemberOfsVersioningCrudEvents;

  if not Supports(fMemberOfConfig, ISelectListFilter<TDtoMember, UInt32>, fSelectListFilter) then
    raise ENotSupportedException.Create('aCrudConfig doesn''t support ISelectListFilter.');

  fRoleListConfig := TCrudConfigRole.Create;
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

  fValueConverter := TDtoMemberConverter.Create(fMemberOfConfig, fRoleMapper);
  fListCrudCommands := TObjectListCrudCommands<TDtoMember, UInt32, TDtoMemberAggregated,
    UInt32, TMemberOfBusinessRecordFilter>.Create(
    fConnection, fSelectListFilter, fMemberOfConfig, fValueConverter);
  fListCrudCommands.TargetEnumerator := fUI;
  fListCrudCommands.CrudEvents := aMemberOfsVersioningCrudEvents;
  fListCrudCommands.OnItemMatchesFilter := OnItemMatchesFilter;
  fListCrudCommands.UseTransaction := True;
end;

destructor TMemberOfBusiness.Destroy;
begin
  fListCrudCommands.Free;
  fValueConverter := nil;
  fRoleMapper.Free;
  fRoleListConfig := nil;
  fSelectListFilter := nil;
  fMemberOfConfig := nil;
  fUI := nil;
  fConnection := nil;
  inherited;
end;

procedure TMemberOfBusiness.ClearRoleCache;
begin
  fRoleMapper.Invalidate;
end;

procedure TMemberOfBusiness.ClearDetailItemCache;
begin
  fMemberOfConfig.GetDetailItemMapper.Invalidate;
end;

function TMemberOfBusiness.GetDetailItemTitle: string;
begin
  Result := fMemberOfConfig.GetDetailItemTitle;
end;

function TMemberOfBusiness.GetShowInactiveMemberOfs: Boolean;
begin
  Result := fCurrentFilter.ShowInactiveMemberOfs;
end;

function TMemberOfBusiness.GetShowVersionInfoInMemberListview: Boolean;
begin
  Result := fMemberOfConfig.GetShowVersionInfoInMemberListview;
end;

function TMemberOfBusiness.CreateNewEntry: TListEntry<TDtoMemberAggregated>;
begin
  Result := TObjectListEntry<TDtoMemberAggregated>.CreateNew(
    TDtoMemberAggregated.Create(fMemberOfConfig, fRoleMapper)
    );
  Result.Data.Active := True;
end;

procedure TMemberOfBusiness.AddNewEntry(const aEntry: TListEntry<TDtoMemberAggregated>);
begin
  var lMember := aEntry.Data.Member;
  fMemberOfConfig.SetMasterItemIdToMember(fCurrentMasterId, lMember);
  aEntry.Data.UpdateByDtoMember(lMember);
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
   fListCrudCommands.FilterSelect := fCurrentMasterId;
  fListCrudCommands.FilterLoop := fCurrentFilter;
  fListCrudCommands.EndUpdateFilter;
end;

procedure TMemberOfBusiness.LoadMemberOfs(const aMasterId: UInt32);
begin
  if fCurrentMasterId = aMasterId then
    Exit;

  fCurrentMasterId := aMasterId;
  UpdateFilter;
end;

procedure TMemberOfBusiness.OnItemMatchesFilter(Sender: TObject; const aItem: TDtoMember;
  const aFilter: TMemberOfBusinessRecordFilter; var aItemMatches: Boolean);
begin
  aItemMatches := aItem.Active or aFilter.ShowInactiveMemberOfs;
end;

function TMemberOfBusiness.SaveEntries(
  const aDeleteEntryFromUICallback: TListCrudCommandsEntryCallback<TDtoMemberAggregated>):
  TCrudSaveResult;
begin
  Result := default(TCrudSaveResult);
  if fCurrentMasterId = 0 then
  begin
    raise EArgumentException.Create('TMemberOfBusiness.SaveEntries: fCurrentMasterId = 0');
  end;

  var lTransaction: ITransaction := fConnection.StartTransaction;
  try
    fListCrudCommands.SaveChanges(aDeleteEntryFromUICallback, lTransaction);
  finally
    if lTransaction.Active then
    begin
      lTransaction.Commit;
      Result := TCrudSaveResult.CreateRecord(TCrudSaveStatus.Successful);
    end
    else
    begin
      Result := TCrudSaveResult.CreateRecord(TCrudSaveStatus.Failed);
    end;
  end;
  if fMemberOfsVersioningCrudEvents.VersionConflictDetected then
  begin
    Result := TCrudSaveResult.CreateConflictedRecord(fMemberOfsVersioningCrudEvents.ConflictedVersionEntry);
  end;
end;

procedure TMemberOfBusiness.ReloadEntries;
begin
  fListCrudCommands
  .Reload;
end;

{ TDtoMemberConverter }

constructor TDtoMemberConverter.Create(const aMemberOfConfig: IMemberOfConfigIntf;
  const aRoleMapper: TKeyIndexStrings);
begin
  inherited Create;
  fMemberOfConfig := aMemberOfConfig;
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
    aTarget := TDtoMemberAggregated.Create(fMemberOfConfig, fRoleMapper, aValue);
  end;
end;

procedure TDtoMemberConverter.ConvertBack(const aValue: TDtoMemberAggregated; var aTarget: TDtoMember);
begin
  aTarget := aValue.Member;
end;

end.
