unit Report.OneUnitMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, SqlConnection, Data.DB, Vcl.StdCtrls,
  Exporter.Types, Exporter.OneUnitMembers, Report.Base.Printout, Exporter.Units.Types;

type
  TfmReportOneUnitMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterUnitDetailsParams>)
    bdColumnHeader: TRLBand;
    Label4: TLabel;
    Label5: TLabel;
    bdDetail: TRLBand;
    RLDBText2: TRLDBText;
    RLDBText3: TRLDBText;
    rdUnitname: TRLDBText;
    rdUnitDataConfirmed: TRLDBText;
    Label1: TLabel;
    rdMemberCount: TRLDBText;
    Label2: TLabel;
    rdUnitDivider: TRLDraw;
    lbAddress: TLabel;
    rtAddress: TRLDBText;
    rdUnitKind: TRLDBText;
    Label3: TLabel;
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure RLReportPageStarting(Sender: TObject);
    procedure rdMemberCountBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure rdUnitKindBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
  strict private
    fNewPageStarted: Boolean;
    procedure SetParams(const aParams: TExporterUnitDetailsParams);
  strict protected
    function GetReportTitle: string; override;
  end;

implementation

uses DtoUnit;

{$R *.dfm}

{ TfmReportOneUnitMembers }

function TfmReportOneUnitMembersPrintout.GetReportTitle: string;
begin
  if Assigned(dsDataSource.DataSet) and not dsDataSource.DataSet.Eof then
    Result := dsDataSource.DataSet.FieldByName('unit_name').AsString
  else
    Result := 'Unbekannte Einheit';
end;

procedure TfmReportOneUnitMembersPrintout.rdMemberCountBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  inherited;
  if rdMemberCount.Field.IsNull then
    AText := '0';
end;

procedure TfmReportOneUnitMembersPrintout.rdUnitKindBeforePrint(Sender: TObject; var AText: string;
  var PrintIt: Boolean);
begin
  inherited;
  AText := UnitKindToStr(TUnitKind(rdUnitKind.Field.AsInteger));
end;

procedure TfmReportOneUnitMembersPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fNewPageStarted := False;
end;

procedure TfmReportOneUnitMembersPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportOneUnitMembersPrintout.SetParams(const aParams: TExporterUnitDetailsParams);
begin

end;

end.
