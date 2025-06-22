unit Report.Birthdays;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls;

type
  TfmReportBirthdays = class(TForm)
    RLReport: TRLReport;
    dsDataSource: TDataSource;
    bdReportHeader: TRLBand;
    lbReportTitle: TLabel;
    lbTenantTitle: TLabel;
    bdColumnHeader: TRLBand;
    lbName: TLabel;
    lbAddress: TLabel;
    bdDetail: TRLBand;
    rdPersonname: TRLDBText;
    rtAddress: TRLDBText;
    bdPageFooter: TRLBand;
    lbSysDate: TRLSystemInfo;
    RLSystemInfo3: TRLSystemInfo;
    RLSystemInfo4: TRLSystemInfo;
    lbAppTitle: TLabel;
    lbBirthday: TLabel;
    rdColumnHeaderHLine: TRLDraw;
    lbAge: TLabel;
    rdBirthdayWeekday: TRLDBText;
    RLDBText1: TRLDBText;
    Label2: TLabel;
    Label1: TLabel;
    lbFromDate: TLabel;
    lbToDate: TLabel;
    rdBirthday: TRLDBText;
    procedure RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  private
    fConnection: ISqlConnection;
    fFromDate: TDate;
    fToDate: TDate;
    fQuery: ISqlPreparedQuery;
    fTempTablename: string;
    procedure InsertDates(const aDates: TArray<TDate>);
  public
    constructor Create(const aConnection: ISqlConnection; const aFromDate, aToDate: TDate); reintroduce;
    procedure Preview;
  end;

implementation

uses System.IOUtils, System.Generics.Collections, System.DateUtils, TenantReader, Vdm.Globals, VclUITools;

{$R *.dfm}

{ TfmReportBirthdays }

constructor TfmReportBirthdays.Create(const aConnection: ISqlConnection; const aFromDate, aToDate: TDate);
begin
  inherited Create(nil);
  fConnection := aConnection;
  fFromDate := aFromDate;
  fToDate := aToDate;
  fTempTablename := 'Birthday_Persons_' + TPath.GetGUIDFileName;
end;

procedure TfmReportBirthdays.Preview;
begin
  RLReport.Preview;
end;

procedure TfmReportBirthdays.rdBirthdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dd.mm.yy', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdays.rdBirthdayWeekdayBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  AText := FormatDateTime('dddd', rdBirthday.Field.AsDateTime);
end;

procedure TfmReportBirthdays.RLReportBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  lbTenantTitle.Caption := TTenantReader.Instance.Tenant.Title;
  lbAppTitle.Caption := TVdmGlobals.GetVdmApplicationTitle;
  lbFromDate.Caption := FormatDatetime('dd.mm.yyyy', fFromDate);
  lbToDate.Caption := FormatDatetime('dd.mm.yyyy', fToDate);

  try
    fConnection.ExecuteCommand('create temporary table ' + fTempTablename + '(birthday date not null primary key)');

    var lDates := TList<TDate>.Create;
    try
      var lBirthday: TDate := fFromDate;
      while CompareDate(lBirthday, fToDate) <= 0 do
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

    var lSelectStmt := 'SELECT p.person_id, p.person_birthday, pn.person_name' +
      ', bt.birthday, year(bt.birthday) - year(p.person_birthday) as age' +
      ' FROM person AS p' +
      ' INNER JOIN vw_person_name AS pn ON pn.person_id = p.person_id' +
      ' INNER JOIN ' + fTempTablename + ' AS bt ON (' +
        ' (month(bt.birthday) = month(p.person_birthday) and day(bt.birthday) = day(p.person_birthday))' +
        ' or (2 = month(p.person_birthday) and 29 = day(p.person_birthday) and not IsLeapYear(bt.birthday) = 1 and month(bt.birthday) = 3 and day(bt.birthday) = 1)' +
      ')' +
      ' LEFT JOIN person_address AS pa ON pa.person_id = p.person_id' +
      ' WHERE p.person_active = 1' +
      ' AND p.person_on_birthday_list = 1' +
      ' AND p.person_birthday is not null' +
      ' ORDER BY bt.birthday, age, pn.person_name';

    fQuery := fConnection.CreatePreparedQuery(lSelectStmt);
    fQuery.ConfigureDatasource(dsDataSource);
    fQuery.Open;
  finally
    fConnection.ExecuteCommand('drop temporary table if exists ' + fTempTablename);
  end;
end;

procedure TfmReportBirthdays.InsertDates(const aDates: TArray<TDate>);
begin
  if Length(aDates) = 0 then
    Exit;

  var lInsertStm := 'insert into ' + fTempTablename + ' values ("' + FormatDateTime('yyyy-mm-dd', aDates[0]) + '")';
  for var i := 1 to High(aDates) do
    lInsertStm := lInsertStm + ', ("' + FormatDateTime('yyyy-mm-dd', aDates[i]) + '")';

  fConnection.ExecuteCommand(lInsertStm);
end;

end.
