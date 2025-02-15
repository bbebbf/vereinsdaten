unit CrudMemberConfigMasterUnit;

interface

uses CrudMemberConfigBase, SqlConnection, DtoMember, DtoPerson, KeyIndexStrings, SelectList, Transaction;

type
  TCrudMemberConfigMasterUnit = class(TCrudMemberConfigBase)
  strict protected
    function GetSelectListSQL: string; override;
    procedure SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery); override;
    function GetDetailItemTitle: string; override;
    function GetDetailItemMapper: TActiveKeyIndexStringsLoader; override;
    function GetShowVersionInfoInMemberListview: Boolean; override;
    procedure SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember); override;
    function GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32; override;
    procedure SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember); override;
  end;

implementation

uses Vdm.Globals, PersonMapper;

{ TCrudMemberConfigMasterUnit }

function TCrudMemberConfigMasterUnit.GetDetailItemMapper: TActiveKeyIndexStringsLoader;
begin
  Result := TPersonMapper.Instance;
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
