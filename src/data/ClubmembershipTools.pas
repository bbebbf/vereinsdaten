unit ClubmembershipTools;

interface

uses SqlConnection;

type
  TClubMembershipNumberCheckerResponse = record
    RequestedNumber: UInt16;
    NumberIsOccupied: Boolean;
    MembershipActive: Boolean;
    OccupiedByPersonId: Int32;
    OccupiedByPersonName: string;
    OccupiedByPersonActive: Boolean;
    function OccupiedToString: string;
  end;

  TClubMembershipNumberChecker = class
  strict private
    fConnection: ISqlConnection;
    fPreparedQuery: ISqlPreparedQuery;
  public
    constructor Create(const aConntection: ISqlConnection);
    function IsMembershipNumberOccupied(const aPersonId: Int32;
      const aMembershipNumber: UInt16): TClubMembershipNumberCheckerResponse;
  end;

implementation

uses System.SysUtils;

const
  OCCUPIED_MESSAGE: string = 'Die Mitgliedsnummer %d wird bereits verwendet durch die %sMitgliedschaft von "%s".';

{ TClubMembershipNumberChecker }

constructor TClubMembershipNumberChecker.Create(const aConntection: ISqlConnection);
begin
  inherited Create;
  fConnection := aConntection;
end;

function TClubMembershipNumberChecker.IsMembershipNumberOccupied(const aPersonId: Int32;
  const aMembershipNumber: UInt16): TClubMembershipNumberCheckerResponse;
begin
  Result := default(TClubMembershipNumberCheckerResponse);
  Result.RequestedNumber := aMembershipNumber;
  if not Assigned(fPreparedQuery) then
  begin
    fPreparedQuery := fConnection.CreatePreparedQuery('SELECT cm.clmb_active, pn.person_id, pn.person_name, p.person_active' +
      ' FROM clubmembership AS cm' +
      ' INNER JOIN person AS p ON p.person_id = cm.person_id' +
      ' INNER JOIN vw_person_name AS pn ON pn.person_id = cm.person_id' +
      ' WHERE cm.person_id <> :PId AND cm.clmb_number = :CNum');
  end;
  fPreparedQuery.Params[0].Value := aPersonId;
  fPreparedQuery.Params[1].Value := aMembershipNumber;
  var lSqlResult := fPreparedQuery.Open;
  if lSqlResult.Next then
  begin
    Result.NumberIsOccupied := True;
    Result.MembershipActive := lSqlResult.Fields[0].AsBoolean;
    Result.OccupiedByPersonId := lSqlResult.Fields[1].AsInteger;
    Result.OccupiedByPersonName := lSqlResult.Fields[2].AsString;
    Result.OccupiedByPersonActive := lSqlResult.Fields[3].AsBoolean;
  end;
end;

{ TClubMembershipNumberCheckerResponse }

function TClubMembershipNumberCheckerResponse.OccupiedToString: string;
begin
  var lPersonName := OccupiedByPersonName;
  if not OccupiedByPersonActive then
    lPersonName := lPersonName + ' (inaktiv)';
  var lMembershipInactive := '';
  if not MembershipActive then
    lMembershipInactive := 'inaktive ';
  Result := Format(OCCUPIED_MESSAGE, [RequestedNumber, lMembershipInactive, lPersonName]);
end;

end.
