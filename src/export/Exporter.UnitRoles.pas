unit Exporter.UnitRoles;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterUnitRoles = class(TExporterBase<TObject>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses Vdm.Globals;

{ TExporterUnitRoles }

function TExporterUnitRoles.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  aQuery := Connection.CreatePreparedQuery(
    'SELECT r.role_id, r.role_name, u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_name' +
    ',pn.person_id,pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ' FROM role AS r' +
    ' INNER JOIN member AS m ON m.role_id = r.role_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' INNER JOIN unit AS u ON u.unit_id = m.unit_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1' +
    ' AND p.person_active = 1' +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', r.role_name, u.unit_name, pn.person_name'
  );
  Result := True;
end;

end.
