unit Exporter.MemberUnits;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterMemberUnits = class(TExporterBase<TObject>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses Vdm.Globals;

{ TExporterMemberUnits }

function TExporterMemberUnits.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  aQuery := Connection.CreatePreparedQuery(
    'SELECT u.unit_id, u.unit_name, u.unit_data_confirmed_on, pn.person_id, pn.person_name, r.role_name' +
    ' FROM unit AS u' +
    ' INNER JOIN member AS m ON m.unit_id = u.unit_id' +
    ' INNER JOIN person AS p ON p.person_id = m.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = m.person_id' +
    ' LEFT JOIN role AS r ON r.role_id = m.role_id' +
    ' WHERE u.unit_active = 1' +
    ' AND m.mb_active = 1' +
    ' AND p.person_active = 1' +
    ' ORDER BY pn.person_name, ' + TVdmGlobals.GetRoleSortingSqlOrderBy('r') + ', u.unit_name'
  );
  Result := True;
end;

end.
