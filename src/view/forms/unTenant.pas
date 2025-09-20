unit unTenant;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoTenant, System.Actions, Vcl.ActnList, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers,  ComponentValueChangedObserver, CrudUI, Vdm.Types, ProgressIndicatorIntf;

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
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
  strict private
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt8, TVoid>;
    fTentantId: UInt8;
    fProgressIndicator: IProgressIndicator;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt8, TVoid>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoTenant);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aTenantId: UInt8);
    function SetSelectedEntry(const aTenantId: UInt8): Boolean;
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoTenant; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoTenant; const aMode: TUIToEntryMode;
      const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
    function GetProgressIndicator: IProgressIndicator;
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

procedure TfmTenant.DeleteEntryFromUI(const aTenantId: UInt8);
begin

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

procedure TfmTenant.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (Key = #27) and not fInEditMode then
  begin
    Key := #0;
    Close;
  end;
end;

procedure TfmTenant.FormShow(Sender: TObject);
begin
  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

function TfmTenant.GetEntryFromUI(var aEntry: TDtoTenant; const aMode: TUIToEntryMode;
  const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
begin
  if TStringTools.IsEmpty(edTenantTitle.Text) then
  begin
    edTenantTitle.SetFocus;
    aProgressUISuspendScope.Suspend;
    TMessageDialogs.Ok('Die Bezeichnung muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  Result := True;
  aEntry.Id := fTentantId;
  aEntry.Title := edTenantTitle.Text;
end;

function TfmTenant.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

procedure TfmTenant.SetCrudCommands(const aCommands: ICrudCommands<UInt8, TVoid>);
begin
  fBusinessIntf := aCommands;
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
  end
  else
  begin
    fTentantId := 1;
    fBusinessIntf.StartNewEntry;
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

function TfmTenant.SetSelectedEntry(const aTenantId: UInt8): Boolean;
begin
  Result := False;
end;

end.
