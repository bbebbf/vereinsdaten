unit Exporter.UnitMembers;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterUnitMembersParams = class
  public
    UnitIds: TArray<UInt32>;
  end;

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
  if Length(Params.UnitIds) > 0 then
  begin
    lTempTablename := CreateTemporaryTable('unit_id int(10) unsigned not null primary key');
    var lUintIdsJoiner := TJoiner<UInt32>.Create;
    try
      lUintIdsJoiner.LineLeading := 'insert into ' + lTempTablename + ' values ';
      lUintIdsJoiner.LineElementLimit := 50;
      lUintIdsJoiner.ElementLeading := '(';
      lUintIdsJoiner.ElementTrailing := ')';
      lUintIdsJoiner.ElementSeparator := ',';
      lUintIdsJoiner.Add(Params.UnitIds);
      for var i in lUintIdsJoiner.Strings do
        Connection.ExecuteCommand(i);
    finally
      lUintIdsJoiner.Free;
    end;

  end;
  var lSelectStm := 'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, mc.MemberCount, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN (' +
          ' SELECT m.unit_id, COUNT(*) AS MemberCount' +
          ' FROM member AS m' +
          ' INNER JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
          ' WHERE  m.mb_active = 1' +
          ' GROUP BY m.unit_id' +
    ') AS mc ON mc.unit_id = u.unit_id';
  if Length(lTempTablename) > 0 then
  begin
    lSelectStm := lSelectStm + ' INNER JOIN ' + lTempTablename + ' AS tt ON tt.unit_id = u.unit_id';
  end;
  lSelectStm := lSelectStm + ' LEFT JOIN member AS m ON m.unit_id = u.unit_id AND m.mb_active = 1' +
    ' LEFT JOIN person AS p ON p.person_id = m.person_id AND p.person_active = 1' +
    ' LEFT JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1' +
    ' ORDER BY u.unit_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', pn.person_name';
  aQuery := Connection.CreatePreparedQuery(lSelectStm);
  Result := True;
end;

end.
