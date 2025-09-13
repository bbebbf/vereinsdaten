unit Exporter.MemberUnits;

interface

uses SqlConnection, Exporter.Base, Exporter.Persons.Types;

type
  TExporterMemberUnits = class(TExporterBase<TExporterPersonsParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses Vdm.Globals;

{ TExporterMemberUnits }

function TExporterMemberUnits.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lSelectSql := 'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_id, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN member AS m ON m.unit_id = u.unit_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1';

  if not Params.ShowInactivePersons then
    lSelectSql := lSelectSql + ' AND p.person_active = 1';
  if not Params.ShowExternalPersons then
    lSelectSql := lSelectSql + ' AND p.person_external = 0';

  lSelectSql := lSelectSql +
    ' ORDER BY pn.person_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name';

  aQuery := Connection.CreatePreparedQuery(lSelectSql);
  Result := True;
end;

end.
