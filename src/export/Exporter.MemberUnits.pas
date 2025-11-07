unit Exporter.MemberUnits;

interface

uses SqlConnection, Exporter.Base, Exporter.Members.Types;

type
  TExporterMemberUnits = class(TExporterBase<TExporterMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses Data.DB, Vdm.Globals;

{ TExporterMemberUnits }

function TExporterMemberUnits.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lSelectSql := 'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_id, pn.person_name, r.role_name' +
    ',pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ',m.mb_active, m.mb_active_until' +
    ',IF(p.person_active, null, "I") AS person_inactive_i' +
    ',IF(p.person_external, "E", null) AS person_external_e' +
    ', p.person_active, p.person_external' +
    ' FROM unit AS u' +
    ' INNER JOIN member AS m ON m.unit_id = u.unit_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1';
  if not Params.Persons.IncludeInactive then
    lSelectSql := lSelectSql + ' AND p.person_active = 1';
  if not Params.Persons.IncludeExternal then
    lSelectSql := lSelectSql + ' AND p.person_external = 0';

  var lInactiveButActiveUntilPresent := False;
  if Params.InactiveMembersButActiveUntil > 0 then
  begin
    lInactiveButActiveUntilPresent := True;
    lSelectSql := lSelectSql + ' AND (m.mb_active = 1' +
      ' OR (m.mb_active = 0 AND (m.mb_active_until is not null AND m.mb_active_until >= :InactiveButActiveUntil)))';
  end
  else if not Params.IncludeAllInactiveMembers then
  begin
    lSelectSql := lSelectSql + ' AND m.mb_active = 1';
  end;

  lSelectSql := lSelectSql +
    ' ORDER BY pn.person_name, m.mb_active DESC, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name';

  aQuery := Connection.CreatePreparedQuery(lSelectSql);
  if lInactiveButActiveUntilPresent then
  begin
    var lParameter := aQuery.ParamByName('InactiveButActiveUntil');
    lParameter.DataType := TFieldType.ftDate;
    lParameter.Value :=  Params.InactiveMembersButActiveUntil;
  end;
  Result := True;
end;

end.
