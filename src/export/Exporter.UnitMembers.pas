unit Exporter.UnitMembers;

interface

uses SqlConnection, Exporter.Base, Exporter.UnitMembers.Types;

type
  TExporterUnitMembers = class(TExporterBase<TExporterUnitMembersParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.SysUtils, Vdm.Globals, Joiner;

{ TExporterUnitMembers }

function TExporterUnitMembers.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lTempTablename := '';
  if Length(Params.CheckedUnitIds) > 0 then
  begin
    lTempTablename := CreateTemporaryTable('unit_id int(10) unsigned not null primary key');
    var lUintIdsJoiner := TJoiner<UInt32>.Create;
    try
      lUintIdsJoiner.LineLeading := 'insert into ' + lTempTablename + ' values ';
      lUintIdsJoiner.LineElementLimit := 50;
      lUintIdsJoiner.ElementLeading := '(';
      lUintIdsJoiner.ElementTrailing := ')';
      lUintIdsJoiner.ElementSeparator := ',';
      lUintIdsJoiner.Add(Params.CheckedUnitIds);
      for var i in lUintIdsJoiner.Strings do
        Connection.ExecuteCommand(i);
    finally
      lUintIdsJoiner.Free;
    end;

  end;
  var lSelectStm := 'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, mc.MemberCount, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' LEFT JOIN (' +
          ' SELECT unit_id, COUNT(*) AS MemberCount' +
          ' FROM vw_active_person_member' +
          ' WHERE mb_active = 1' +
          ' GROUP BY unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id';
  if Length(lTempTablename) > 0 then
  begin
    lSelectStm := lSelectStm + ' INNER JOIN ' + lTempTablename + ' AS tt ON tt.unit_id = u.unit_id';
  end;
  lSelectStm := lSelectStm + ' LEFT JOIN vw_active_person_member AS m ON m.unit_id = u.unit_id and m.mb_active = 1' +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' ORDER BY u.unit_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name';
  aQuery := Connection.CreatePreparedQuery(lSelectStm);
  Result := True;
end;

end.
