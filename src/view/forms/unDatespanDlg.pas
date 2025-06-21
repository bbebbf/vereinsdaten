unit unDatespanDlg;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, DatespanProvider, Nullable, Vcl.ComCtrls, Vcl.StdCtrls;

type
  TfmDatespanDlg = class(TForm, IDatespanProvider)
    dtFromDate: TDateTimePicker;
    dtToDate: TDateTimePicker;
    btConfirm: TButton;
    btCancel: TButton;
    Label1: TLabel;
    Label2: TLabel;
    procedure dtFromDateChange(Sender: TObject);
    procedure dtToDateChange(Sender: TObject);
  private
    fFromDate: INullable<TDate>;
    fToDate: INullable<TDate>;

    function ProvideDatespan: Boolean;
    function GetTitle: string;
    procedure SetTitle(const aTitle: string);
    function GetAllowedKinds: TDatespanKinds;
    procedure SetAllowedKinds(const aKinds: TDatespanKinds);
    function GetFromDate: INullable<TDate>;
    procedure SetFromDate(const aFromDate: TDate);
    function GetToDate: INullable<TDate>;
    procedure SetToDate(const aToDate: TDate);
  public
  end;

implementation

{$R *.dfm}

uses System.DateUtils;

{ TfmDatespanDlg }

procedure TfmDatespanDlg.dtFromDateChange(Sender: TObject);
begin
  if CompareDate(dtFromDate.Date, dtToDate.Date) > 0  then
    dtToDate.Date := dtFromDate.Date;
end;

procedure TfmDatespanDlg.dtToDateChange(Sender: TObject);
begin
  if CompareDate(dtToDate.Date, dtFromDate.Date) < 0  then
    dtFromDate.Date := dtToDate.Date;
end;

function TfmDatespanDlg.GetAllowedKinds: TDatespanKinds;
begin
  Result := [];
end;

function TfmDatespanDlg.GetFromDate: INullable<TDate>;
begin
  if not Assigned(fFromDate) then
    fFromDate := TNullable<TDate>.Create;
  fFromDate.Value := dtFromDate.Date;
  Result := fFromDate;
end;

function TfmDatespanDlg.GetTitle: string;
begin
  Result := Caption;
end;

function TfmDatespanDlg.GetToDate: INullable<TDate>;
begin
  if not Assigned(fToDate) then
    fToDate := TNullable<TDate>.Create;
  fToDate.Value := dtToDate.Date;
  Result := fToDate;
end;

function TfmDatespanDlg.ProvideDatespan: Boolean;
begin
  Result := ShowModal = mrOk;
end;

procedure TfmDatespanDlg.SetAllowedKinds(const aKinds: TDatespanKinds);
begin

end;

procedure TfmDatespanDlg.SetFromDate(const aFromDate: TDate);
begin
  dtFromDate.Date := aFromDate;
end;

procedure TfmDatespanDlg.SetTitle(const aTitle: string);
begin
  Caption := aTitle;
end;

procedure TfmDatespanDlg.SetToDate(const aToDate: TDate);
begin
  dtToDate.Date := aToDate;
end;

end.
