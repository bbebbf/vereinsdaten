unit CrudMemberConfigMasterPerson;

interface

uses CrudMemberConfigBase, SqlConnection, DtoMember, DtoUnit, KeyIndexStrings, SelectList;

type
  TCrudMemberConfigMasterPerson = class(TCrudMemberConfigBase)
  strict protected
    function GetSelectListSQL: string; override;
    procedure SetSelectListSQLParameter(const aFilter: UInt32; const aQuery: ISqlPreparedQuery); override;
    function GetDetailItemTitle: string; override;
    function GetDetailItemMapper: TActiveKeyIndexStringsLoader; override;
    procedure SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember); override;
    function GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32; override;
    procedure SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember); override;
  end;

implementation

uses Vdm.Globals, UnitMapper;

{ TCrudMemberConfigMasterPerson }

function TCrudMemberConfigMasterPerson.GetDetailItemMapper: TActiveKeyIndexStringsLoader;
begin
  Result := TUnitMapper.Instance.Data;
end;

function TCrudMemberConfigMasterPerson.GetDetailItemTitle: string;
begin
  Result := 'Einheit';
end;

function TCrudMemberConfigMasterPerson.GetSelectListSQL: string;
begin
  Result := 'SELECT m.*'
    + ' FROM member AS m'
    + ' INNER JOIN unit AS u ON u.unit_id = m.unit_id'
    + ' LEFT JOIN role AS r ON r.role_id = m.role_id'
    + ' WHERE m.person_id = :PId'
    + ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name, m.mb_active_since DESC';
end;

procedure TCrudMemberConfigMasterPerson.SetSelectListSQLParameter(const aFilter: UInt32;
  const aQuery: ISqlPreparedQuery);
begin
  aQuery.ParamByName('PId').Value := aFilter;
end;

function TCrudMemberConfigMasterPerson.GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32;
begin
  Result := aMember.UnitId;
end;

procedure TCrudMemberConfigMasterPerson.SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember);
begin
  aMember.UnitId := aDetailItemId;
end;

procedure TCrudMemberConfigMasterPerson.SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember);
begin
  aMember.PersonId := aMasterItemId;
end;

end.
