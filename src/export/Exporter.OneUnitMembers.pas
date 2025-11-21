unit Exporter.OneUnitMembers;

interface

uses SqlConnection, Exporter.Base, Exporter.Units.Types;

type
  TExporterOneUnitMembers = class(TExporterBase<TExporterUnitDetailsParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Vdm.Globals;

{ TExporterOneUnitMembers }

function TExporterOneUnitMembers.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  aQuery := Connection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, u.unit_kind, u.unit_data_confirmed_on, mc.unit_member_count' +
    ', pn.person_name, a.address_title, r.role_name' +
    ', pn.person_id,pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ', a.address_street,a.address_postalcode,a.address_city' +
    ' FROM unit AS u' +
    ' LEFT JOIN (' +
          ' SELECT unit_id, COUNT(*) AS unit_member_count' +
          ' FROM vw_active_person_member' +
          ' WHERE mb_active = 1' +
          ' GROUP BY unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id' +
    ' LEFT JOIN vw_active_person_member AS m ON m.unit_id = u.unit_id AND m.mb_active = 1' +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = m.person_id' +
    ' LEFT JOIN vw_select_address AS a ON a.adr_id = pa.adr_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_id = ' + UIntToStr(Params.SelectedUnitId) +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name'
  );
  Result := True;
end;

end.
