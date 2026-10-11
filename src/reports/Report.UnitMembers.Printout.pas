unit Report.UnitMembers.Printout;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RLReport, Data.DB, Vcl.StdCtrls,
  SqlConnection, Exporter.Types, Exporter.Members.Types, Report.Base.Printout;

type
  TfmReportUnitMembersPrintout = class(TfmReportBasePrintout, IExporterTarget<TExporterMembersParams>)
    bdColumnHeader: TRLBand;
    lbUnit: TLabel;
    lbPerson: TLabel;
    lbRole: TLabel;
    bdDetail: TRLBand;
    rdUnitname: TRLDBText;
    rdPersonname: TRLDBText;
    rdRolename: TRLDBText;
    rdUinitId: TRLDBText;
    rdUnitDivider: TRLDraw;
    lbDataConfirmed: TLabel;
    rdUnitDataConfirmed: TRLDBText;
    rdMemberCount: TRLDBText;
    lbUnitKind: TLabel;
    rdUnitKind: TRLDBText;
    rdInactiveInfo: TRLLabel;
    rdInactiveInfoUnit: TRLLabel;
    procedure bdDetailAfterPrint(Sender: TObject);
    procedure rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
    procedure rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
    procedure RLReportPageStarting(Sender: TObject);
    procedure bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
  strict private
    fParams: TExporterMembersParams;
    fPreviousUnitId: UInt32;
    fNewPageStarted: Boolean;
    fOneUnitPerPage: Boolean;
    fDefaultDetailHeight: Integer;
    procedure SetParams(const aParams: TExporterMembersParams);
  strict protected
    function GetReportTitle: string; override;
    procedure DoBeforePrint; override;
  end;

implementation

uses Vdm.Globals, DtoUnit, StringTools, Exporter.Params.Tools;

{$R *.dfm}

{ TfmReportUnitMembers }

function TfmReportUnitMembersPrintout.GetReportTitle: string;
begin
  Result := 'Einheiten und Personen';
end;

procedure TfmReportUnitMembersPrintout.bdDetailBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lActiveRecordInfo := default(TActiveRecordInfo);
  fParams.Units.State.GetActiveRecordInfo(rdUnitname.DataSet, lActiveRecordInfo);
  if lActiveRecordInfo.Active then
    rdUnitname.Font.Style := []
  else
    rdUnitname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfoUnit.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfoUnit.Caption := lActiveRecordInfo.InactiveInfoStr;

  lActiveRecordInfo := default(TActiveRecordInfo);
  lActiveRecordInfo.Active := rdUnitname.DataSet.FieldByName('person_active').AsBoolean;
  fParams.MembersState.GetActiveRecordInfo(rdUnitname.DataSet, lActiveRecordInfo, 'Verbindung');
  if lActiveRecordInfo.Active then
    rdPersonname.Font.Style := []
  else
    rdPersonname.Font.Style := [TFontStyle.fsStrikeOut];
  rdInactiveInfo.Visible := Length(lActiveRecordInfo.InactiveInfoStr) > 0;
  rdInactiveInfo.Caption := lActiveRecordInfo.InactiveInfoStr;

  if not rdInactiveInfoUnit.Visible and not rdInactiveInfo.Visible then
    bdDetail.Height := fDefaultDetailHeight;

  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  if fOneUnitPerPage then
  begin
    if not fNewPageStarted and lUnitBreak then
    begin
      bdDetail.FGreenBarFlag := False;
      bdDetail.PageBreaking := pbBeforePrint
    end
    else
    begin
      bdDetail.PageBreaking := pbNone;
    end;
  end;
end;

procedure TfmReportUnitMembersPrintout.bdDetailAfterPrint(Sender: TObject);
begin
  fPreviousUnitId := rdUinitId.Field.AsLargeInt;
  fNewPageStarted := False;
end;

procedure TfmReportUnitMembersPrintout.rdUnitDividerBeforePrint(Sender: TObject; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
end;

procedure TfmReportUnitMembersPrintout.rdUnitnameBeforePrint(Sender: TObject; var AText: string; var PrintIt: Boolean);
begin
  var lUnitBreak := rdUinitId.Field.AsLargeInt <> fPreviousUnitId;
  PrintIt := fNewPageStarted or lUnitBreak;
  if (Sender = rdUnitname) and (rdMemberCount.Field.AsInteger > 5) then
  begin
    AText := AText + ' (' + IntToStr(rdMemberCount.Field.AsInteger) + ' Pers.)';
  end
  else if Sender = rdUnitKind then
  begin
    AText := UnitKindToStrShort(TUnitKind(rdUnitKind.Field.AsInteger));
  end
  else if Sender = rdUnitDataConfirmed then
  begin
    AText := TVdmGlobals.GetDateAsString(rdUnitDataConfirmed.Field.AsDateTime);
  end;
end;

procedure TfmReportUnitMembersPrintout.DoBeforePrint;
begin
  inherited;
  fPreviousUnitId := 0;
  fDefaultDetailHeight := (2 * rdUnitname.Top) + rdUnitname.Height;
end;

procedure TfmReportUnitMembersPrintout.RLReportPageStarting(Sender: TObject);
begin
  fNewPageStarted := True;
end;

procedure TfmReportUnitMembersPrintout.SetParams(const aParams: TExporterMembersParams);
begin
  fParams := aParams;
  var lFilterInfo := '';
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.Units.State.GetReadableCondition);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak, aParams.MembersState.GetReadableCondition);
  lFilterInfo := TStringTools.Combine(lFilterInfo, sLineBreak,
    GetPersonInclusionInfo(aParams.Persons.IncludeInactive, aParams.Persons.IncludeExternal));

  SetFilterInfo(lFilterInfo);
end;

end.
