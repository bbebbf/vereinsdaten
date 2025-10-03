unit Exporter.Birthdays;


interface

uses SqlConnection, Exporter.Types, Exporter.Base, Exporter.Birthdays.Types;

type
  TExporterBirthdays = class(TExporterBase<TExporterBirthdaysParams>)
  strict private
    procedure DateToDbStr(Sender: TObject; const aElement: TDate; var aElementStr: string);
  strict protected
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.DateUtils, Vdm.Globals, Joiner;

{ TExporterBirthdays }

function TExporterBirthdays.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lTempTablename := CreateTemporaryTable('birthday date not null primary key');

  var lDatesJoiner := TJoiner<TDate>.Create;
  try
    lDatesJoiner.LineLeading := 'insert into ' + lTempTablename + ' values ';
    lDatesJoiner.LineElementLimit := 50;
    lDatesJoiner.ElementSeparator := ',';
    lDatesJoiner.OnElementToStr := DateToDbStr;
    var lBirthday: TDate := Params.FromDate;
    while CompareDate(lBirthday, Params.ToDate) <= 0 do
    begin
      lDatesJoiner.Add(lBirthday);
      lBirthday := IncDay(lBirthday);
    end;
    for var i in lDatesJoiner.Strings do
      Connection.ExecuteCommand(i);
  finally
    lDatesJoiner.Free;
  end;

  var lSelectStmt := 'SELECT p.person_id, p.person_date_of_birth, pn.person_name' +
    ', bt.birthday, year(bt.birthday) - year(p.person_date_of_birth) as age' +
    ', pn.person_lastname,pn.person_firstname,pn.person_nameaddition' +
    ' FROM person AS p' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' INNER JOIN ' + lTempTablename + ' AS bt ON (' +
      ' (month(bt.birthday) = p.person_month_of_birth and day(bt.birthday) = p.person_day_of_birth)' +
      ' or (2 = p.person_month_of_birth and 29 = p.person_day_of_birth and not IsLeapYear(bt.birthday) = 1 and month(bt.birthday) = 3 and day(bt.birthday) = 1)' +
    ')' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' WHERE p.person_active = 1' +
    ' AND p.person_external = 0' +
    ' AND p.person_day_of_birth is not null' +
    ' AND p.person_month_of_birth is not null';

  if Params.ConsiderBirthdaylistFlag then
  begin
    lSelectStmt := lSelectStmt + ' AND p.person_on_birthday_list = 1';
  end;

  if Params.SortedByName then
  begin
    lSelectStmt := lSelectStmt + ' ORDER BY pn.person_name, bt.birthday, age';
  end
  else
  begin
    lSelectStmt := lSelectStmt + ' ORDER BY bt.birthday, age, pn.person_name';
  end;

  aQuery := Connection.CreatePreparedQuery(lSelectStmt);
  Result := True;
end;

procedure TExporterBirthdays.DateToDbStr(Sender: TObject; const aElement: TDate; var aElementStr: string);
begin
  aElementStr := '(''' + FormatDateTime('yyyy-mm-dd', aElement) + ''')';
end;

end.
