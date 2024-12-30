unit ListCrudCommands;

interface

uses System.SysUtils, System.Generics.Collections, SqlConnection, FilterSelect, SelectListFilter,
  ListEnumerator, CrudConfig, ListCrudCommands.Types, ValueConverter, Transaction;

type
  TListEntry<T> = class
  strict private
    fData: T;
    fState: TListEntryCrudState;
    fStateBeforeToBeDeleted: TListEntryCrudState;
  public
    constructor Create(const aData: T);
    constructor CreateNew(const aData: T);
    procedure Updated;
    procedure ToggleToBeDeleted;
    procedure Resetted;
    property Data: T read fData;
    property State: TListEntryCrudState read fState;
  end;

  TObjectListEntry<T: class> = class(TListEntry<T>)
  public
    destructor Destroy; override;
  end;

  TListCrudCommandsDestinationFromSource<TS, TD> = reference to procedure(const aSource: TS; var aDestination: TD);
  TListCrudCommandsSourceFromDestination<TD, TS> = reference to procedure(const aSource: TD; var aDestination: TS);
  TListCrudCommandsEntryCallback<T> = reference to procedure(const aEntry: TListEntry<T>);

  TListCrudCommands<TS, TSIdent: record; TD; FSelect, FLoop: record> = class(TFilterSelect<TS, FSelect, FLoop>)
  strict private
    fConnection: ISqlConnection;
    fCrudConfig: ICrudConfig<TS, TSIdent>;
    fItems: TList<TListEntry<TD>>;
    fValueConverter: IValueConverter<TS, TD>;
    fTargetEnumerator: IListEnumerator<TListEntry<TD>>;
  strict protected
    function CreateListEntry(const aItem: TD): TListEntry<TD>; virtual;
    procedure FilterChanged; override;
    procedure ListEnumBegin; override;
    procedure ListEnumProcessItem(const aItem: TS); override;
    procedure ListEnumEnd; override;
  public
    constructor Create(const aConnection: ISqlConnection;
      const aSelectListFilter: ISelectListFilter<TS, FSelect>;
      const aCrudConfig: ICrudConfig<TS, TSIdent>;
      const aValueConverter: IValueConverter<TS, TD>
      );
    destructor Destroy; override;
    procedure Reload;
    procedure SaveChanges(const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TD>;
      const aTransaction: ITransaction = nil);
    property TargetEnumerator: IListEnumerator<TListEntry<TD>> read fTargetEnumerator write fTargetEnumerator;
    property Items: TList<TListEntry<TD>> read fItems;
  end;

  TObjectListCrudCommands<TS, TSIdent: record; TD: class; FSelect, FLoop: record> =
    class(TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>)
  strict protected
    function CreateListEntry(const aItem: TD): TListEntry<TD>; override;
  end;

implementation

uses RecordActions;

{ TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop> }

constructor TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.Create(const aConnection: ISqlConnection;
  const aSelectListFilter: ISelectListFilter<TS, FSelect>;
  const aCrudConfig: ICrudConfig<TS, TSIdent>;
  const aValueConverter: IValueConverter<TS, TD>
  );
begin
  inherited Create(aConnection, aSelectListFilter);
  fConnection := aConnection;
  fCrudConfig := aCrudConfig;
  fValueConverter := aValueConverter;
end;

destructor TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.Destroy;
begin
  fItems.Free;
  fValueConverter := nil;
  fCrudConfig := nil;
  fConnection := nil;
  inherited;
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.FilterChanged;
begin
  inherited;
  ApplyFilter;
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.ListEnumBegin;
begin
  inherited;
  if Assigned(fItems) then
  begin
    fItems.Clear;
  end
  else
  begin
    fItems := TObjectList<TListEntry<TD>>.Create;
  end;
  if Assigned(fTargetEnumerator) then
    fTargetEnumerator.ListEnumBegin;
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.ListEnumEnd;
begin
  inherited;
  if Assigned(fTargetEnumerator) then
    fTargetEnumerator.ListEnumEnd;
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.ListEnumProcessItem(const aItem: TS);
begin
  inherited;
  var lTargetItem := default(TD);
  fValueConverter.Convert(aItem, lTargetItem);
  var lEntry := CreateListEntry(lTargetItem);
  fItems.Add(lEntry);
  if Assigned(fTargetEnumerator) then
    fTargetEnumerator.ListEnumProcessItem(lEntry);
end;

function TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.CreateListEntry(const aItem: TD): TListEntry<TD>;
begin
  Result := TListEntry<TD>.Create(aItem);
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.Reload;
begin
  FreeAndNil(fItems);
  ApplyFilter;
end;

procedure TListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.SaveChanges(
  const aDeleteEntryCallback: TListCrudCommandsEntryCallback<TD>;
  const aTransaction: ITransaction);
begin
  var lRecordActions := TRecordActions<TS, TSIdent>.Create(fConnection, fCrudConfig);
  try
    var lTransaction := aTransaction;
    var lOwnsTransaction := False;
    if not Assigned(lTransaction) then
    begin
      lTransaction := fConnection.StartTransaction;
      lOwnsTransaction := True;
    end;
    for var i := fItems.Count - 1 downto 0 do
    begin
      var lEntry := fItems[i];
      if lEntry.State = TListEntryCrudState.NewDeleted then
      begin
        aDeleteEntryCallback(lEntry);
      end
      else if lEntry.State in [TListEntryCrudState.Updated, TListEntryCrudState.New] then
      begin
        var lTS := default(TS);
        var lTD := lEntry.Data;
        fValueConverter.ConvertBack(lTD, lTS);
        lRecordActions.SaveRecord(lTS, lTransaction);
        fValueConverter.Convert(lTS, lTD);
        lEntry.Resetted;
      end
      else if lEntry.State = TListEntryCrudState.ToBeDeleted then
      begin
        var lTS := default(TS);
        fValueConverter.ConvertBack(lEntry.Data, lTS);
        lRecordActions.DeleteEntry(fCrudConfig.GetRecordIdentity(lTS), lTransaction);
        aDeleteEntryCallback(lEntry);
        fItems.Delete(i);
      end;
    end;
    if lOwnsTransaction then
      lTransaction.Commit;
  finally
    lRecordActions.Free;
  end;
end;

{ TListEntry<T> }

constructor TListEntry<T>.Create(const aData: T);
begin
  inherited Create;
  fData := aData;
  fState := TListEntryCrudState.Unchanged;
end;

constructor TListEntry<T>.CreateNew(const aData: T);
begin
  inherited Create;
  fData := aData;
  fState := TListEntryCrudState.New;
end;

procedure TListEntry<T>.Resetted;
begin
  fState := TListEntryCrudState.Unchanged;
end;

procedure TListEntry<T>.ToggleToBeDeleted;
begin
  if fState = TListEntryCrudState.ToBeDeleted then
  begin
    fState := fStateBeforeToBeDeleted;
  end
  else if fState = TListEntryCrudState.NewDeleted then
  begin
    fState := TListEntryCrudState.New;
  end
  else
  begin
    fStateBeforeToBeDeleted := fState;
    if fState = TListEntryCrudState.New then
    begin
      fState := TListEntryCrudState.NewDeleted;
    end
    else
    begin
      fState := TListEntryCrudState.ToBeDeleted;
    end;
  end;
end;

procedure TListEntry<T>.Updated;
begin
  if fState <> TListEntryCrudState.New then
    fState := TListEntryCrudState.Updated;
end;

{ TObjectListEntry<T> }

destructor TObjectListEntry<T>.Destroy;
begin
  Data.Free;
  inherited;
end;

{ TObjectListCrudCommands<TS, TSIdent, TD, FSelect, FLoop> }

function TObjectListCrudCommands<TS, TSIdent, TD, FSelect, FLoop>.CreateListEntry(const aItem: TD): TListEntry<TD>;
begin
  Result := TObjectListEntry<TD>.Create(aItem);
end;

end.
