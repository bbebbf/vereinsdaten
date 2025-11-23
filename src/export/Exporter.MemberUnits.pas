unit Exporter.MemberUnits;

interface

uses SqlConnection, Exporter.Base, Exporter.Members.Types;

type
  TExporterMemberUnits = class(TExporterBase<TExporterMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Data.DB, Vdm.Globals, SqlConditionBuilder, DtoUnit;

{ TExporterMemberUnits }

function TExporterMemberUnits.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lMemberStateJoinWhere := Params.MembersState.Get('m');
  var lUnitState := Params.Units.State.Get('u');

  var lSelectSql := 'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_id, pn.person_name, r.role_name' +
    ',pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ',m.mb_active, m.mb_active_until' +
    ',IF(p.person_active, null, "I") AS person_inactive_i' +
    ',IF(p.person_external, "E", null) AS person_external_e' +
    ', p.person_active, p.person_external' +
    ' FROM unit AS u' +
    ' INNER JOIN member AS m ON m.unit_id = u.unit_id ' + lMemberStateJoinWhere.GetSqlCondition('AND') +
    ' INNER JOIN person AS p ON p.person_id = m.person_id';

  if not Params.Persons.IncludeInactive then
    lSelectSql := lSelectSql + ' AND p.person_active = 1';
  if not Params.Persons.IncludeExternal then
    lSelectSql := lSelectSql + ' AND p.person_external = 0';

  var lUnitConditions := TSqlConditionBuilder.CreateAnd;
  lUnitConditions.Add(False).Value := lUnitState.GetSqlCondition;
  var lUnitConditionsKind := lUnitConditions.AddAnd;
  for var i := Succ(Low(TUnitKind)) to High(TUnitKind) do
  begin
    if not (i in Params.Units.Kinds) then
      lUnitConditionsKind.AddNotEquals
        .SetLeftValue('u.unit_kind')
        .SetRightValue(IntToStr(Ord(i)));
  end;
  var lUnitConditionsStr := lUnitConditions.GetConditionString(TSqlConditionStart.WhereStart);

  lSelectSql := lSelectSql +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id ' + lUnitConditionsStr;

  lSelectSql := lSelectSql +
    ' ORDER BY pn.person_name, m.mb_active DESC, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name';

  aQuery := Connection.CreatePreparedQuery(lSelectSql);
  lMemberStateJoinWhere.ApplyParameters(aQuery);
  lUnitState.ApplyParameters(aQuery);
  Result := True;
end;

end.
