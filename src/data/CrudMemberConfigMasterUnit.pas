unit CrudMemberConfigMasterUnit;

interface

uses CrudMemberConfigBase, SqlConnection, DtoMember, DtoPerson, KeyIndexStrings, SelectList, Transaction;

type
  TCrudMemberConfigMasterUnit = class(TCrudMemberConfigBase)
  strict private
    fConnection: ISqlConnection;
    fDetailItemListConfig: ISelectList<TDtoPerson>;
    fDetailItemMapper: TActiveKeyIndexStringsLoader;
  strict protected
    function GetSelectListSQL: string; override;
    procedure SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery); override;
    function GetDetailItemTitle: string; override;
    function GetDetailItemMapper: TActiveKeyIndexStringsLoader; override;
    function GetShowVersionInfoInMemberListview: Boolean; override;
    procedure SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember); override;
    function GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32; override;
    procedure SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember); override;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
  end;

implementation

uses Vdm.Globals, CrudConfigPerson;

{ TCrudMemberConfigMasterUnit }

constructor TCrudMemberConfigMasterUnit.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConnection;
end;

destructor TCrudMemberConfigMasterUnit.Destroy;
begin
  fDetailItemMapper.Free;
  fDetailItemListConfig := nil;
  inherited;
end;

function TCrudMemberConfigMasterUnit.GetDetailItemMapper: TActiveKeyIndexStringsLoader;
begin
  if not Assigned(fDetailItemMapper) then
  begin
    fDetailItemListConfig := TCrudConfigPerson.Create;
    fDetailItemMapper := TActiveKeyIndexStringsLoader.Create(
        function(var aData: TActiveKeyIndexStrings): Boolean
        begin
          Result := True;
          aData := TActiveKeyIndexStrings.Create;
          var lSqlResult := fConnection.GetSelectResult(fDetailItemListConfig.GetSelectListSQL);
          while lSqlResult.Next do
          begin
            var lRecord := default(TDtoPerson);
            fDetailItemListConfig.GetRecordFromSqlResult(lSqlResult, lRecord);
            aData.AddString(lRecord.NameId.Id, lRecord.Active, lRecord.ToString);
          end;
        end
      );
  end;
  Result := fDetailItemMapper;
end;

function TCrudMemberConfigMasterUnit.GetDetailItemTitle: string;
begin
  Result := 'Person';
end;

function TCrudMemberConfigMasterUnit.GetSelectListSQL: string;
begin
  Result := 'SELECT m.*'
    + ' FROM member AS m'
    + ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id'
    + ' LEFT JOIN role AS r ON r.role_id = m.role_id'
    + ' WHERE m.unit_id = :UId'
    + ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name, m.mb_active_since DESC';
end;

function TCrudMemberConfigMasterUnit.GetShowVersionInfoInMemberListview: Boolean;
begin
  Result := True;
end;

procedure TCrudMemberConfigMasterUnit.SetSelectListSQLParameter(const aFilter: UInt32;
  const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('UId').Value := aFilter;
end;

function TCrudMemberConfigMasterUnit.GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32;
begin
  Result := aMember.PersonId;
end;

procedure TCrudMemberConfigMasterUnit.SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember);
begin
  aMember.PersonId := aDetailItemId;
end;

procedure TCrudMemberConfigMasterUnit.SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember);
begin
  aMember.UnitId := aMasterItemId;
end;

end.
