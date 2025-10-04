unit Exporter.Persons;

interface

uses SqlConnection, Exporter.Base, Exporter.Persons.Types;

type
  TExporterPersons = class(TExporterBase<TExporterPersonsParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

{ TExporterPersons }

function TExporterPersons.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lSelectStmt := 'SELECT p.person_id, p.person_active, pn.person_name, a.address_title' +
    ',p.person_date_of_birth, p.person_day_of_birth, p.person_month_of_birth' +
    ',IF(p.person_active, null, "I") AS person_inactive_i' +
    ',IF(p.person_external, "E", null) AS person_external_e' +
    ',p.person_external' +
    ',pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ',a.address_street,a.address_postalcode,a.address_city' +
    ' FROM person AS p' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' LEFT JOIN vw_select_address AS a ON a.adr_id = pa.adr_id' +
    ' WHERE 1=1';
  if not Params.ShowInactivePersons then
    lSelectStmt := lSelectStmt + ' AND p.person_active = 1';
  if not Params.ShowExternalPersons then
    lSelectStmt := lSelectStmt + ' AND p.person_external = 0';
  lSelectStmt := lSelectStmt + ' ORDER BY pn.person_name';
  aQuery := Connection.CreatePreparedQuery(lSelectStmt);
  Result := True;
end;

end.
