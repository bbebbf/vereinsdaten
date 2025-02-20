unit unRole;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  System.Generics.Collections, CrudCommands, DtoRole, ExtendedListview, Vcl.Menus, Vcl.ExtCtrls,
  Vcl.ComCtrls, Vcl.WinXPickers, System.Actions, Vcl.ActnList,
  ComponentValueChangedObserver, CrudUI, Vdm.Types, ProgressIndicatorIntf;

type
  TfmRole = class(TForm, ICrudUI<TDtoRole, TDtoRole, UInt32, TVoid>)
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
    lbListviewItemCount: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
    procedure acSaveCurrentEntryExecute(Sender: TObject);
    procedure acReloadCurrentEntryExecute(Sender: TObject);
    procedure acStartNewEntryExecute(Sender: TObject);
    procedure lvListviewDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  strict private
    fComponentValueChangedObserver: TComponentValueChangedObserver;
    fInEditMode: Boolean;
    fBusinessIntf: ICrudCommands<UInt32, TVoid>;
    fExtendedListview: TExtendedListview<TDtoRole>;
    fDelayedLoadEntry: TDelayedLoadEntry;
    fProgressIndicator: IProgressIndicator;

    procedure SetEditMode(const aEditMode: Boolean);
    procedure StartEdit;
    procedure ControlValuesChanged(Sender: TObject);
    procedure ControlValuesUnchanged(Sender: TObject);
    procedure EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);

    procedure SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aEntry: TDtoRole);
    procedure ListEnumEnd;
    procedure DeleteEntryFromUI(const aUnitId: UInt32);
    procedure ClearEntryFromUI;
    procedure SetEntryToUI(const aEntry: TDtoRole; const aMode: TEntryToUIMode);
    function GetEntryFromUI(var aEntry: TDtoRole; const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
    procedure LoadCurrentEntry(const aEntryId: UInt32);
    function GetProgressIndicator: IProgressIndicator;
  end;

implementation

{$R *.dfm}

uses System.Generics.Defaults, StringTools, MessageDialogs, Vdm.Globals;

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
  StartEdit;
end;

procedure TfmRole.ClearEntryFromUI;
begin
  fComponentValueChangedObserver.BeginUpdate;

  edRoleName.Text := '';
  edRoleSorting.Text := '';
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

procedure TfmRole.FormCreate(Sender: TObject);
begin
  fComponentValueChangedObserver := TComponentValueChangedObserver.Create;
  fComponentValueChangedObserver.OnValuesChanged := ControlValuesChanged;
  fComponentValueChangedObserver.OnValuesUnchanged := ControlValuesUnchanged;

  fComponentValueChangedObserver.RegisterEdit(edRoleName);
  fComponentValueChangedObserver.RegisterEdit(edRoleSorting);

  fExtendedListview := TExtendedListview<TDtoRole>.Create(lvListview,
    procedure(const aData: TDtoRole; const aListItem: TListItem)
    begin
      aListItem.Caption := aData.ToString;
    end,
    TComparer<TDtoRole>.Construct(
      function(const aLeft, aRight: TDtoRole): Integer
      begin
        Result := TVdmGlobals.CompareId(aLeft.Id, aRight.Id);
      end
    )
  );
  fDelayedLoadEntry := TDelayedLoadEntry.Create(
    procedure(const aData: TDelayedLoadEntryData)
    begin
      if aData.RecordFound then
      begin
        LoadCurrentEntry(aData.RecordId);
        if aData.StartEdit then
          StartEdit;
      end
      else
      begin
        acStartNewEntry.Execute;
      end;
    end,
    200
  );
end;

procedure TfmRole.FormDestroy(Sender: TObject);
begin
  fDelayedLoadEntry.Free;
  fExtendedListview.Free;
  fComponentValueChangedObserver.Free;
end;

procedure TfmRole.FormShow(Sender: TObject);
begin
  SetEditMode(False);
  fBusinessIntf.LoadList;
end;

function TfmRole.GetEntryFromUI(var aEntry: TDtoRole; const aProgressUISuspendScope: IProgressUISuspendScope): Boolean;
begin
  if TStringTools.IsEmpty(edRoleName.Text) then
  begin
    edRoleName.SetFocus;
    aProgressUISuspendScope.Suspend;
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
      aProgressUISuspendScope.Suspend;
      TMessageDialogs.Ok('Die Sorting muss ein Wert zwischen 0 und 255 sein.', TMsgDlgType.mtInformation);
      Exit(False);
    end;
  end;

  Result := True;
  aEntry.Name := edRoleName.Text;
  aEntry.Sorting := lSortingInteger;
end;

function TfmRole.GetProgressIndicator: IProgressIndicator;
begin
  Result := fProgressIndicator;
end;

procedure TfmRole.SetCrudCommands(const aCommands: ICrudCommands<UInt32, TVoid>);
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
  fExtendedListview.BeginUpdate;
  fExtendedListview.Clear;
end;

procedure TfmRole.ListEnumProcessItem(const aEntry: TDtoRole);
begin
  fExtendedListview.Add(aEntry);
end;

procedure TfmRole.ListEnumEnd;
begin
  if lvListview.Items.Count > 0 then
  begin
    lvListview.Items[0].Selected := True;
  end;
  fExtendedListview.EndUpdate;
  lbListviewItemCount.Caption := IntToStr(lvListview.Items.Count) + ' Datensätze';
  lvListview.SetFocus;
end;

procedure TfmRole.lvListviewDblClick(Sender: TObject);
begin
  if Assigned(lvListview.Selected) then
    EnqueueLoadEntry(lvListview.Selected, True);
end;

procedure TfmRole.lvListviewSelectItem(Sender: TObject; Item: TListItem; Selected: Boolean);
begin
  if Selected then
    EnqueueLoadEntry(Item, False)
  else
    EnqueueLoadEntry(nil, False)
end;

procedure TfmRole.EnqueueLoadEntry(const aListItem: TListItem; const aDoStartEdit: Boolean);
begin
  if fComponentValueChangedObserver.InUpdated then
    Exit;

  var lRecordFound := False;
  var lRecord: TDtoRole;
  if Assigned(aListItem) then
  begin
    lRecordFound := fExtendedListview.TryGetListItemData(aListItem, lRecord);
  end;
  fDelayedLoadEntry.SetData(TDelayedLoadEntryData.Create(lRecord.Id, lRecordFound, aDoStartEdit));
end;

procedure TfmRole.SetEditMode(const aEditMode: Boolean);
begin
  var lInEditModeBefore := fInEditMode;
  fInEditMode := aEditMode;
  acSaveCurrentEntry.Enabled := fInEditMode;
  acReloadCurrentEntry.Enabled := fInEditMode;
  if lInEditModeBefore and not fInEditMode then
    lvListview.SetFocus;
end;

procedure TfmRole.SetEntryToUI(const aEntry: TDtoRole; const aMode: TEntryToUIMode);
begin
  fComponentValueChangedObserver.BeginUpdate;

  edRoleName.Text := aEntry.Name;
  edRoleSorting.Text := IntToStr(aEntry.Sorting);

  fExtendedListview.UpdateData(aEntry);
  fComponentValueChangedObserver.EndUpdate;
end;

procedure TfmRole.StartEdit;
begin
  edRoleName.SetFocus;
  SetEditMode(True);
end;

end.
