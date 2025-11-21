unit Exporter.UnitMembers;

interface

uses SqlConnection, Exporter.Base, Exporter.Members.Types;

type
  TExporterUnitMembers = class(TExporterBase<TExporterMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Vdm.Globals, Joiner;

{ TExporterUnitMembers }

function TExporterUnitMembers.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lTempTablename := '';
  if Params.Units.CheckedUnitIds.Count > 0 then
  begin
    lTempTablename := CreateTemporaryTable('unit_id int(10) unsigned not null primary key');
    var lUnitIdsJoiner := TJoiner<UInt32>.Create;
    try
      lUnitIdsJoiner.LineLeading := 'insert into ' + lTempTablename + ' values ';
      lUnitIdsJoiner.LineElementLimit := 50;
      lUnitIdsJoiner.ElementLeading := '(';
      lUnitIdsJoiner.ElementTrailing := ')';
      lUnitIdsJoiner.ElementSeparator := ',';
      lUnitIdsJoiner.Add(Params.Units.CheckedUnitIds);
      for var i in lUnitIdsJoiner.Strings do
        Connection.ExecuteCommand(i);
    finally
      lUnitIdsJoiner.Free;
    end;
  end;

  var lMemberStateFromWhere := Params.MembersState.Get('', 'mc');
  var lMemberStateJoinWhere := Params.MembersState.Get('m');
  var lUnitState := Params.Units.State.Get('u');

  var lSelectStm := 'SELECT u.unit_id, u.unit_name, u.unit_kind, u.unit_data_confirmed_on, mc.unit_member_count' +
    ',pn.person_name, r.role_name' +
    ',pn.person_id,pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ' FROM unit AS u' +
    ' LEFT JOIN (' +
          ' SELECT unit_id, COUNT(*) AS unit_member_count' +
          ' FROM vw_person_member ' + lMemberStateFromWhere.GetSqlCondition('WHERE') +
          ' GROUP BY unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id';
  if Length(lTempTablename) > 0 then
  begin
    lSelectStm := lSelectStm + ' INNER JOIN ' + lTempTablename + ' AS tt ON tt.unit_id = u.unit_id';
  end;
  lSelectStm := lSelectStm + ' LEFT JOIN vw_person_member AS m ON m.unit_id = u.unit_id ' +
    lMemberStateJoinWhere.GetSqlCondition('AND');

  if not Params.Persons.IncludeInactive then
    lSelectStm := lSelectStm + ' AND m.person_active = 1';
  if not Params.Persons.IncludeExternal then
    lSelectStm := lSelectStm + ' AND m.person_external = 0';

  lSelectStm := lSelectStm +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = m.person_id ' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' ' + lUnitState.GetSqlCondition('WHERE') +
    ' ORDER BY u.unit_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name';
  aQuery := Connection.CreatePreparedQuery(lSelectStm);
  lUnitState.ApplyParameters(aQuery);
  lMemberStateFromWhere.ApplyParameters(aQuery);
  lMemberStateJoinWhere.ApplyParameters(aQuery);
  Result := True;
end;

end.
