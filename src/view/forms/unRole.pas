unit unRole;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoRole, ListviewAttachedData, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, DelayedExecute, Vdm.Types;

type
  TfmRole = class(TForm, ICrudUI<TDtoRole, TDtoRole, UInt32>)
    pnListview: TPanel;
    Splitter1: TSplitter;
    pnDetails: TPanel;
    lvListview: TListView;
    alActionList: TActionList;
    acSaveCurrentEntry: TAction;
    acReloadCurrentEntry: TAction;
    pnFilter: TPanel;
    acStartNewEntry: TAction;
    btStartNewRecord: TButton;
    lbRoleName: TLabel;
    edRoleName: TEdit;
    btSave: TButton;
    btReload: TButton;
    edRoleSorting: TEdit;
    lbSorting: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
  strict private
    fActivated: Boolean;
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32>;
    fListviewAttachedData: TListviewAttachedData<UInt32, TVoid>;
    fDelayedExecute: TDelayedExecute<TPair<Boolean, UInt32>>;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    function EntryToListItem(const aEntry: TDtoRole; const aItem: TListItem): TListItem;

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoRole);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoRole; const aAsNewEntry: Boolean);
    function GetEntryFromUI(var aEntry: TDtoRole): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);
  public
    { Public-Deklarationen }
  end;

implementation

{$R *.dfm}

uses StringTools, MessageDialogs;

{ TfmRole }

procedure TfmRole.acReloadCurrentEntryExecute(Sender: TObject);
begin
  fBusinessIntf.ReloadCurrentEntry;
  SetEditMode(False);
end;

procedure TfmRole.acSaveCurrentEntryExecute(Sender: TObject);
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

procedure TfmRole.acStartNewEntryExecute(Sender: TObject);
begin
  fBusinessIntf.StartNewEntry;
  SetEditMode(False);
end;

procedure TfmRole.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edRoleName.Text := '';
  edRoleSorting.Text := '0';
  edRoleName.SetFocus;
  fComponentValueChangedObserver.EndUpdate;
end;

procedure TfmRole.ControlValuesChanged(Sender: TObject);
begin
  SetEditMode(True);
end;

procedure TfmRole.ControlValuesUnchanged(Sender: TObject);
begin
  SetEditMode(False);
end;

procedure TfmRole.DeleteEntryFromUI(const aUnitId: UInt32);
begin

end;

procedure TfmRole.FormActivate(Sender: TObject);
begin
  if fActivated then
    Exit;
  fActivated := True;

  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

procedure TfmRole.FormCreate(Sender: TObject);
begin
  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edRoleName);
  fComponentValueChangedObserver.RegisterEdit(edRoleSorting);

  fListviewAttachedData := TListviewAttachedData<UInt32, TVoid>.Create(lvListview);
  fDelayedExecute := TDelayedExecute<TPair<Boolean, UInt32>>.Create(
    procedure(const aData: TPair<Boolean, UInt32>)
    begin
      if aData.Key then
      begin
        LoadCurrentEntry(aData.Value);
      end
      else
      begin
        ClearEntryFromUI;
      end;
    end,
    200
  );
end;

procedure TfmRole.FormDestroy(Sender: TObject);
begin
  fDelayedExecute.Free;
  fListviewAttachedData.Free;
  fComponentValueChangedObserver.Free;
end;

function TfmRole.GetEntryFromUI(var aEntry: TDtoRole): Boolean;
begin
  if TStringTools.IsEmpty(edRoleName.Text) then
  begin
    edRoleName.SetFocus;
    TMessageDialogs.Ok('Die Bezeichnung muss angegeben sein.', TMsgDlgType.mtInformation);
    Exit(False);
  end;

  var lSortingInteger := 0;
  if Length(edRoleSorting.Text) > 0 then
  begin
    lSortingInteger := StrToIntDef(edRoleSorting.Text, 0);
    if (lSortingInteger < 0) or (lSortingInteger > 255) then
    begin
      edRoleName.SetFocus;
      TMessageDialogs.Ok('Die Sorting muss ein Wert zwischen 0 und 255 sein.', TMsgDlgType.mtInformation);
      Exit(False);
    end;
  end;

  Result := True;
  aEntry.Name := edRoleName.Text;
  aEntry.Sorting := lSortingInteger;
end;

procedure TfmRole.SetCrudCommands(const aCommands: ICrudCommands<UInt32>);
begin
  fBusinessIntf := aCommands;
end;

procedure TfmRole.LoadCurrentEntry(const aEntryId: UInt32);
begin
  fBusinessIntf.LoadCurrentEntry(aEntryId);
  SetEditMode(False);
end;

procedure TfmRole.ListEnumBegin;
begin
  lvListview.Items.BeginUpdate;
  fListviewAttachedData.Clear;
end;

procedure TfmRole.ListEnumProcessItem(const aEntry: TDtoRole);
begin
  EntryToListItem(aEntry, nil);
end;

procedure TfmRole.ListEnumEnd;
begin
  lvListview.Items.EndUpdate;
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
end;

procedure TfmRole.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  var lEntryFound := False;
  var lEntryId: UInt32 := 0;
  if Selected then
  begin
    lEntryFound := fListviewAttachedData.TryGetKey(Item, lEntryId);
  end;

  fDelayedExecute.SetData(TPair<Boolean, UInt32>.Create(lEntryFound, lEntryId));
end;

function TfmRole.EntryToListItem(const aEntry: TDtoRole; const aItem: TListItem): TListItem;
begin
  Result := aItem;
  if Assigned(Result) then
  begin
    fListviewAttachedData.UpdateItem(aItem, aEntry.Id, default(TVoid));
  end
  else
  begin
    Result := fListviewAttachedData.AddItem(aEntry.Id, default(TVoid));
  end;
  Result.Caption := aEntry.ToString;
end;

procedure TfmRole.SetEditMode(const aEditMode: Boolean);
begin
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
end;

procedure TfmRole.SetEntryToUI(const aEntry: TDtoRole; const aAsNewEntry: Boolean);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edRoleName.Text := aEntry.Name;
  edRoleSorting.Text := IntToStr(aEntry.Sorting);

  if aAsNewEntry then
  begin
    var lNewItem := EntryToListItem(aEntry, nil);
    lNewItem.Selected := True;
    lNewItem.MakeVisible(False);
  end
  else
  begin
    EntryToListItem(aEntry, lvListview.Selected);
  end;

  fComponentValueChangedObserver.EndUpdate;
end;

end.
