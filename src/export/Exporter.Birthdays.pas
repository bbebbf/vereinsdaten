unit Exporter.Birthdays;


interface

uses SqlConnection, Exporter.TargetIntf, Exporter.Base;

type
  TExporterBirthdaysParams = class
  public
    FromDate: TDate;
    ToDate: TDate;
  end;

  TExporterBirthdays = class(TExporterBase<TExporterBirthdaysParams>)
  strict private
    fTempTablename: string;
    procedure InsertDates(const aDates: TArray<TDate>);
  strict protected
    procedure PrepareExport; override;
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; override;
    procedure CleanupAfterExport; override;
  end;

implementation

uses System.Generics.Collections, System.SysUtils, System.DateUtils, System.IOUtils, Vdm.Globals;

{ TExporterBirthdays }

function TExporterBirthdays.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  var lDates := TList<TDate>.Create;
  try
    var lBirthday: TDate := Params.FromDate;
    while CompareDate(lBirthday, Params.ToDate) <= 0 do
    begin
      if lDates.Count = 50 then
      begin
        InsertDates(lDates.ToArray);
        lDates.Clear;
      end;
      lDates.Add(lBirthday);
      lBirthday := IncDay(lBirthday);
    end;
    InsertDates(lDates.ToArray);
  finally
    lDates.Free;
  end;

  var lSelectStmt := 'SELECT p.person_id, p.person_date_of_birth, pn.person_name' +
    ', bt.birthday, year(bt.birthday) - year(p.person_date_of_birth) as age' +
    ' FROM person AS p' +
    ' INNER JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
    ' INNER JOIN ' + fTempTablename + ' AS bt ON (' +
      ' (month(bt.birthday) = p.person_month_of_birth and day(bt.birthday) = p.person_day_of_birth)' +
      ' or (2 = p.person_month_of_birth and 29 = p.person_day_of_birth and not IsLeapYear(bt.birthday) = 1 and month(bt.birthday) = 3 and day(bt.birthday) = 1)' +
    ')' +
    ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
    ' WHERE p.person_active = 1' +
    ' AND p.person_on_birthday_list = 1' +
    ' AND p.person_day_of_birth is not null' +
    ' AND p.person_month_of_birth is not null' +
    ' ORDER BY bt.birthday, age, pn.person_name';

  aQuery := Connection.CreatePreparedQuery(lSelectStmt);
  Result := True;
end;

procedure TExporterBirthdays.InsertDates(const aDates: TArray<TDate>);
begin
  if Length(aDates) = 0 then
    Exit;

  var lInsertStm := 'insert into ' + fTempTablename + ' values ("' + FormatDateTime('yyyy-mm-dd', aDates[0]) + '")';
  for var i := 1 to High(aDates) do
    lInsertStm := lInsertStm + ', ("' + FormatDateTime('yyyy-mm-dd', aDates[i]) + '")';

  Connection.ExecuteCommand(lInsertStm);
end;

procedure TExporterBirthdays.PrepareExport;
begin
  fTempTablename := 'Birthday_Persons_' + TPath.GetGUIDFileName;
  Connection.ExecuteCommand('create temporary table ' + fTempTablename + '(birthday date not null primary key)');
end;

procedure TExporterBirthdays.CleanupAfterExport;
begin
  Connection.ExecuteCommand('drop temporary table if exists ' + fTempTablename);
end;

end.
