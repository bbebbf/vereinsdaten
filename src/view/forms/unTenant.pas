unit unTenant;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoTenant, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers,  ComponentValueChangedObserver, CrudUI, Vdm.Types;

type
  TfmTenant = class(TForm, ICrudUI<TDtoTenant, TDtoTenant, UInt8, TVoid>)
    alActionList: TActionList;
    acSaveCurrentEntry: TAction;
    acReloadCurrentEntry: TAction;
    lbTenantTitle: TLabel;
    edTenantTitle: TEdit;
    btSave: TButton;
    btReload: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt8, TVoid>;
    fTentantId: UInt8;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt8, TVoid>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoTenant);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt8);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoTenant; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoTenant): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt8);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses StringTools, MessageDialogs;

{ TfmTenant }

procedure TfmTenant.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfmTenant.acSaveCurrentEntryExecute(Sender: TObject);
begin
  var lResponse := fBusinessIntf.SaveCurrentEntry;
  if lResponse.Status = TCrudSaveStatus.Successful then
  begin
    SetEditMode(False);
  end
  else if lResponse.Status = TCrudSaveStatus.CancelledWithMessage then
  begin
    TMessageDialogs.Ok(lResponse.MessageText, TMsgDlgType.mtInformation);
  end;
end;

procedure TfmTenant.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  SetEditMode(False);
end;

procedure TfmTenant.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edTenantTitle.Text := '';
  fComponentValueChangedObserver.EndUpdate;
end;

procedure TfmTenant.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmTenant.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmTenant.DeleteEntryFromUI(const aUnitId: UInt8);
begin

end;

procedure TfmTenant.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;

  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

procedure TfmTenant.FormCreate(Sender: TObject);
begin
  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edTenantTitle);
end;

procedure TfmTenant.FormDestroy(Sender: TObject);
begin
  fComponentValueChangedObserver.Free;
end;

function TfmTenant.GetEntryFromUI(var aEntry: TDtoTenant): Boolean;
begin
  if TStringTools.IsEmpty(edTenantTitle.Text) then
  begin
    edTenantTitle.SetFocus;
    TMessageDialogs.Ok('Die Bezeichnung muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Title := edTenantTitle.Text;
end;

procedure TfmTenant.SetCrudCommands(const aCommands: ICrudCommands<UInt8, TVoid>);
begin
  fBusinessIntf := aCommands;
end;

procedure TfmTenant.LoadCurrentEntry(const aEntryId: UInt8);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  SetEditMode(False);
end;

procedure TfmTenant.ListEnumBegin;
begin
  fTentantId := 0;
end;

procedure TfmTenant.ListEnumProcessItem(const aEntry: TDtoTenant);
begin
  fTentantId := aEntry.Id;
end;

procedure TfmTenant.ListEnumEnd;
begin
  if fTentantId > 0 then
  begin
    fBusinessIntf.LoadCurrentEntry(fTentantId);
  end;
end;

procedure TfmTenant.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
end;

procedure TfmTenant.SetEntryToUI(const aEntry: TDtoTenant; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;
  edTenantTitle.Text := aEntry.Title;
  fComponentValueChangedObserver.EndUpdate;
end;

end.
