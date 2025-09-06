unit Exporter.OneUnitMembers;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterOneUnitMembersParams = class
  public
    UnitId: UInt32;
  end;

  TExporterOneUnitMembers = class(TExporterBase<TExporterOneUnitMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Vdm.Globals;

{ TExporterOneUnitMembers }

function TExporterOneUnitMembers.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  aQuery := Connection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, mc.MemberCount, pn.person_name, p.person_date_of_birth, a.address_title, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN (' +
          ' SELECT m.unit_id, COUNT(*) AS MemberCount' +
          ' FROM member AS m' +
          ' INNER JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
          ' WHERE  m.mb_active = 1' +
          ' GROUP BY m.unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id' +
    ' LEFT JOIN member AS m ON m.unit_id = u.unit_id AND m.mb_active = 1' +
    ' LEFT JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' LEFT JOIN vw_select_address AS a ON a.adr_id = pa.adr_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_id = ' + UIntToStr(Params.UnitId) +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name'
  );
  Result := True;
end;

end.
