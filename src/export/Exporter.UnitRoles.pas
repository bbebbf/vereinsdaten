unit Exporter.UnitRoles;

interface

uses SqlConnection, Exporter.Base, Exporter.Members.Types;

type
  TExporterUnitRoles = class(TExporterBase<TExporterMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Vdm.Globals, SqlConditionBuilder, DtoUnit;

{ TExporterUnitRoles }

function TExporterUnitRoles.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lUnitState := Params.Units.State.Get('u');
  var lMemberState := Params.MembersState.Get('m');

  var lConditions := TSqlConditionBuilder.CreateAnd;
  lConditions.Add(False).Value := lUnitState.GetSqlCondition;
  lConditions.Add(False).Value := lMemberState.GetSqlCondition;
  for var i := Succ(Low(TUnitKind)) to High(TUnitKind) do
  begin
    if not (i in Params.Units.Kinds) then
      lConditions.AddNotEquals
        .SetLeftValue('u.unit_kind')
        .SetRightValue(IntToStr(Ord(i)));
  end;
  if not Params.Persons.IncludeInactive then
    lConditions.AddEquals
      .SetLeftValue('p.person_active')
      .SetRightValue('1');
  if not Params.Persons.IncludeExternal then
    lConditions.AddEquals
      .SetLeftValue('p.person_external')
      .SetRightValue('0');

  var lConditionsStr := lConditions.GetConditionString(TSqlConditionStart.WhereStart);

  aQuery := Connection.CreatePreparedQuery(
    'SELECT r.role_id, r.role_name, u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_name' +
    ',pn.person_id,pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ' FROM role AS r' +
    ' INNER JOIN member AS m ON m.role_id = r.role_id' +
    ' INNER JOIN unit AS u ON u.unit_id = m.unit_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' ' + lConditionsStr +
    ' ORDER BY ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', r.role_name, u.unit_name, pn.person_name'
  );
  Result := True;
end;

end.
