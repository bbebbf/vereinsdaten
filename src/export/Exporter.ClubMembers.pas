unit Exporter.ClubMembers;

interface

uses SqlConnection, Exporter.Base;

type
  TExporterClubMembers = class(TExporterBase<TObject>)
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

{ TExporterClubMembers }

function TExporterClubMembers.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  aQuery := Connection.CreatePreparedQuery(
    'SELECT cm.*, pn.person_name, p.person_date_of_birth, sa.address_title' +
    ', IFNULL(DATE_FORMAT(cm.clmb_enddate, ''%d.%m.%Y''), cm.clmb_enddate_str) AS clmb_enddate_calculated' +
    ', IF(cm.clmb_active, null, "X") AS clmb_inactive' +
    ', pn.person_id,pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ', sa.address_street,sa.address_postalcode,sa.address_city' +
    ' FROM clubmembership AS cm' +
    ' INNER JOIN person AS p ON p.person_id = cm.person_id' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = cm.person_id' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = cm.person_id' +
    ' LEFT JOIN vw_select_address AS sa ON sa.adr_id = pa.adr_id' +
    ' ORDER BY cm.clmb_number, pn.person_name'
  );
  Result := True;
end;

end.
