unit Exporter.Persons;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterPersonsParams = class
  public
    ShowInactivePersons: Boolean;
  end;

  TExporterPersons = class(TExporterBase<TExporterPersonsParams>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

{ TExporterPersons }

function TExporterPersons.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lSelectStmt := 'SELECT p.person_id, p.person_active, p.person_date_of_birth, pn.person_name, a.address_title' +
    ',IF(p.person_active, null, "X") AS person_inactive' +
    ' FROM person AS p' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' LEFT JOIN vw_select_address AS a ON a.adr_id = pa.adr_id';
  if not Params.ShowInactivePersons then
    lSelectStmt := lSelectStmt + ' WHERE p.person_active = 1';
  lSelectStmt := lSelectStmt + ' ORDER BY pn.person_name';
  aQuery := Connection.CreatePreparedQuery(lSelectStmt);
  Result := True;
end;

end.
