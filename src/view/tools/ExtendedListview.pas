unit ExtendedListview;

interface

uses System.Generics.Collections, System.Generics.Defaults, Vcl.ComCtrls, InterfacedBase;

type
  TExtendedListviewDataToListItem<T> = reference to procedure(const aData: T; const aListItem: TListItem);
  TExtendedListviewDataToId<T, K> = reference to function(const aData: T): K;
  TExtendedListviewDataPredicate<F, T> = reference to function(const aFilterExpression: F; const aData: T): Boolean;
  TExtendedListviewCompareColumn<T> = reference to procedure(const aData1, aData2: T;
    const aColumnIndex: Integer; var aCompareResult: Integer; var aHandled: Boolean);

  TExtendedListviewOnEndUpdateEvent = procedure(Sender: TObject; const aTotalItemCount, aVisibleItemCount: Integer) of object;

  TExtendedListviewEntry<T> = class
  strict private
    fData: T;
    fChecked: Boolean;
    fListItem: TListItem;
  strict protected
    procedure SetData(const aValue: T); virtual;
  public
    property Data: T read fData write SetData;
    property Checked: Boolean read fChecked write fChecked;
    property ListItem: TListItem read fListItem write fListItem;
  end;

  TExtendedListview<T; K: record> = class
  strict private
    fListview: TListView;
    fDataItemsOwner: TObjectList<TExtendedListviewEntry<T>>;
    fDataItemsSortedList: TList<TExtendedListviewEntry<T>>;
    fDataItemsAreSorted: Boolean;
    fDataToListItemFunc: TExtendedListviewDataToListItem<T>;
    fDataToIdFunc: TExtendedListviewDataToId<T, K>;
    fDataIdComparer: IComparer<K>;
    fListItemToEntryDict: TDictionary<TListItem, TExtendedListviewEntry<T>>;
    fOnEndUpdate: TExtendedListviewOnEndUpdateEvent;
    fColumnClickedColumn: TListColumn;
    fColumnClickedSortDescending: Boolean;
    fOnCompareColumn: TExtendedListviewCompareColumn<T>;
    fImageIndexSortUp: Integer;
    fImageIndexSortDown: Integer;
    fCheckedIds: THashSet<K>;
    fCheckedIdsDirty: Boolean;
    procedure ClearListItems;
    function AddListItem(const aEntry: TExtendedListviewEntry<T>): TListItem;
    procedure SortDataItems;
    procedure UpdateListItem(const aEntry: TExtendedListviewEntry<T>);
    procedure OnListviewColumnClick(Sender: TObject; Column: TListColumn);
    procedure LVCompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
    procedure LVItemCheckedEvent(Sender: TObject; Item: TListItem);
  private
    function GetCheckedIds: TArray<K>;
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; virtual;
  public
    constructor Create(const aListview: TListView;
      const aDataToListItemFunc: TExtendedListviewDataToListItem<T>;
      const aDataToIdFunc: TExtendedListviewDataToId<T, K>;
      const aDataIdComparer: IComparer<K>);
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure ClearCheckedIds;
    function Add(const aData: T): TListItem;
    function Delete(const aData: T): Boolean;
    procedure InvalidateListItems;
    function UpdateData(const aData: T; const aCreateEntryIfNotExists: Boolean = True): Boolean;
    function TryGetListItemData(const aListItem: TListItem; out aData: T): Boolean;
    function TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
    procedure Filter<F>(const aFilterExpression: F; const aPredicate: TExtendedListviewDataPredicate<F, T>);
    property OnEndUpdate: TExtendedListviewOnEndUpdateEvent read fOnEndUpdate write fOnEndUpdate;
    property OnCompareColumn: TExtendedListviewCompareColumn<T> read fOnCompareColumn write fOnCompareColumn;
    property ImageIndexSortUp: Integer read fImageIndexSortUp write fImageIndexSortUp;
    property ImageIndexSortDown: Integer read fImageIndexSortDown write fImageIndexSortDown;
    property CheckedIds: TArray<K> read GetCheckedIds;
  end;

  TExtendedListviewObjectEntry<T: class> = class(TExtendedListviewEntry<T>)
  strict protected
    procedure SetData(const aValue: T); override;
  public
    destructor Destroy; override;
  end;

  TObjectExtendedListview<T: class; K: record> = class(TExtendedListview<T, K>)
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; override;
  end;

implementation

uses System.Classes, System.SysUtils, Winapi.Windows;

{ TExtendedListview<T, K> }

constructor TExtendedListview<T, K>.Create(const aListview: TListView;
  const aDataToListItemFunc: TExtendedListviewDataToListItem<T>;
  const aDataToIdFunc: TExtendedListviewDataToId<T, K>;
  const aDataIdComparer: IComparer<K>);
begin
  inherited Create;
  fListview := aListview;
  fListview.OnColumnClick := OnListviewColumnClick;
  fListview.OnCompare := LVCompareEvent;
  fListview.OnItemChecked := LVItemCheckedEvent;
  fDataToListItemFunc := aDataToListItemFunc;
  fDataToIdFunc := aDataToIdFunc;
  fDataItemsOwner := TObjectList<TExtendedListviewEntry<T>>.Create;

  fDataIdComparer := aDataIdComparer;
  if not Assigned(fDataIdComparer) then
    fDataIdComparer := TComparer<K>.Default;

  var lEntryComparer: IComparer<TExtendedListviewEntry<T>> := TComparer<TExtendedListviewEntry<T>>.Construct(
      function(const aLeft, aRight: TExtendedListviewEntry<T>): Integer
      begin
        Result := fDataIdComparer.Compare(fDataToIdFunc(aLeft.Data), fDataToIdFunc(aRight.Data));
      end
    );
  fDataItemsSortedList := TList<TExtendedListviewEntry<T>>.Create(lEntryComparer);

  fListItemToEntryDict := TDictionary<TListItem, TExtendedListviewEntry<T>>.Create;
  fDataItemsAreSorted := True;
  fImageIndexSortUp := -1;
  fImageIndexSortDown := -1;

  fCheckedIds := THashSet<K>.Create;
end;

destructor TExtendedListview<T, K>.Destroy;
begin
  fCheckedIds.Free;
  fListItemToEntryDict.Free;
  fDataItemsSortedList.Free;
  fDataItemsOwner.Free;
  inherited;
end;

function TExtendedListview<T, K>.Add(const aData: T): TListItem;
begin
  var lEntry := CreateEntry;
  lEntry.Data := aData;
  lEntry.Checked := fCheckedIds.Contains(fDataToIdFunc(aData));
  fDataItemsOwner.Add(lEntry);
  fDataItemsSortedList.Add(lEntry);
  Result := AddListItem(lEntry);
  fDataItemsAreSorted := False;
end;

procedure TExtendedListview<T, K>.Clear;
begin
  ClearListItems;
  fDataItemsSortedList.Clear;
  fDataItemsOwner.Clear;
  fDataItemsAreSorted := True;
end;

procedure TExtendedListview<T, K>.ClearCheckedIds;
begin
  if fCheckedIdsDirty then
  begin
    for var lEntry in fDataItemsOwner do
      lEntry.Checked := False;
    for var lItem in fListview.Items do
      lItem.Checked := False;
    fCheckedIdsDirty := False;
  end;
  fCheckedIds.Clear;
end;

function TExtendedListview<T, K>.AddListItem(const aEntry: TExtendedListviewEntry<T>): TListItem;
begin
  Result := fListview.Items.Add;
  Result.ImageIndex := -1;
  Result.Checked := fListview.Checkboxes and aEntry.Checked;
  aEntry.ListItem := Result;
  fListItemToEntryDict.Add(Result, aEntry);
  UpdateListItem(aEntry);
end;

procedure TExtendedListview<T, K>.ClearListItems;
begin
  fListItemToEntryDict.Clear;
  fListview.Items.Clear;
  for var i := 0 to fListview.Columns.Count - 1 do
    fListview.Columns[i].ImageIndex := -1;
end;

procedure TExtendedListview<T, K>.BeginUpdate;
begin
  fListview.Items.BeginUpdate;
end;

procedure TExtendedListview<T, K>.EndUpdate;
begin
  if Assigned(fOnEndUpdate) then
    fOnEndUpdate(Self, fDataItemsOwner.Count, fListview.Items.Count);
  fListview.Items.EndUpdate;
end;

procedure TExtendedListview<T, K>.Filter<F>(const aFilterExpression: F;
  const aPredicate: TExtendedListviewDataPredicate<F, T>);
begin
  BeginUpdate;
  try
    ClearListItems;
    for var lEntry in fDataItemsOwner do
    begin
      if aPredicate(aFilterExpression, lEntry.Data) then
        AddListItem(lEntry)
      else
        lEntry.ListItem := nil;
    end;
  finally
    EndUpdate;
  end;
end;

function TExtendedListview<T, K>.GetCheckedIds: TArray<K>;
begin
  Result := fCheckedIds.ToArray;
end;

procedure TExtendedListview<T, K>.InvalidateListItems;
begin
  BeginUpdate;
  try
    for var lEntry in fDataItemsOwner do
    begin
      UpdateListItem(lEntry);
    end;
  finally
    EndUpdate;
  end;
end;

procedure TExtendedListview<T, K>.LVCompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer;
  var Compare: Integer);
begin
  Compare := 0;
  var lHandled := False;
  if Assigned(fOnCompareColumn) then
  begin
    var lData1 := default(T);
    if not TryGetListItemData(Item1, lData1) then
      lData1 := default(T);
    var lData2 := default(T);
    if not TryGetListItemData(Item2, lData2) then
      lData2 := default(T);
    lHandled := True;
    fOnCompareColumn(lData1, lData2, Data, Compare, lHandled);
  end;
  if not lHandled then
  begin
    var lText1 := '';
    if Data = 0 then
      lText1 := Item1.Caption
    else if Data <= Item1.SubItems.Count then
      lText1 := Item1.SubItems[Data - 1];
    var lText2 := '';
    if Data = 0 then
      lText2 := Item2.Caption
    else if Data <= Item2.SubItems.Count then
      lText2 := Item2.SubItems[Data - 1];
    Compare := CompareText(lText1, lText2);
  end;
  if fColumnClickedSortDescending and (Compare <> 0) then
    Compare := -Compare;
end;

procedure TExtendedListview<T, K>.LVItemCheckedEvent(Sender: TObject; Item: TListItem);
begin
  fCheckedIdsDirty := True;
  if not fListview.Checkboxes then
    Exit;

  var lEntry: TExtendedListviewEntry<T>;
  if not fListItemToEntryDict.TryGetValue(Item, lEntry) then
    Exit;

  lEntry.Checked := Item.Checked;
  if lEntry.Checked then
    fCheckedIds.Add(fDataToIdFunc(lEntry.Data))
  else
    fCheckedIds.Remove(fDataToIdFunc(lEntry.Data));
end;

procedure TExtendedListview<T, K>.OnListviewColumnClick(Sender: TObject; Column: TListColumn);
begin
  if fColumnClickedColumn = Column then
  begin
    fColumnClickedSortDescending := not fColumnClickedSortDescending;
  end
  else
  begin
    if Assigned(fColumnClickedColumn) then
    begin
      fColumnClickedColumn.ImageIndex := -1;
    end;
    fColumnClickedColumn := Column;
    fColumnClickedSortDescending := False;
  end;
  if fColumnClickedSortDescending then
  begin
    fColumnClickedColumn.ImageIndex := fImageIndexSortDown;
  end
  else
  begin
    fColumnClickedColumn.ImageIndex := fImageIndexSortUp;
  end;
  fListview.CustomSort(nil, fColumnClickedColumn.Index);
end;

procedure TExtendedListview<T, K>.SortDataItems;
begin
  if fDataItemsAreSorted then
    Exit;
  fDataItemsSortedList.Sort;
  fDataItemsAreSorted := True;
end;

function TExtendedListview<T, K>.TryGetListItemData(const aListItem: TListItem; out aData: T): Boolean;
begin
  aData := default(T);
  var lEntry: TExtendedListviewEntry<T>;
  if not fListItemToEntryDict.TryGetValue(aListItem, lEntry) then
    Exit(False);

  aData := lEntry.Data;
  Result := True;
end;

function TExtendedListview<T, K>.TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
begin
  SortDataItems;
  var lSearchEntry := CreateEntry;
  try
    lSearchEntry.Data := aData;
    var lFoundIndex: Integer;
    if not fDataItemsSortedList.BinarySearch(lSearchEntry, lFoundIndex) then
      Exit(False);

    var lFoundEntry := fDataItemsSortedList[lFoundIndex];
    if not Assigned(lFoundEntry.ListItem) then
      Exit(False);

    aListItem := lFoundEntry.ListItem;
    Result := True;
  finally
    lSearchEntry.Free;
  end;
end;

function TExtendedListview<T, K>.Delete(const aData: T): Boolean;
begin
  SortDataItems;
  var lSearchEntry := CreateEntry;
  try
    lSearchEntry.Data := aData;
    var lFoundIndex: Integer;
    if not fDataItemsSortedList.BinarySearch(lSearchEntry, lFoundIndex) then
      Exit(False);

    var lFoundEntry := fDataItemsSortedList[lFoundIndex];

    lFoundEntry.ListItem.Free;
    fDataItemsOwner.Delete(lFoundIndex);
    fDataItemsOwner.Remove(lFoundEntry);

    Result := True;
  finally
    lSearchEntry.Free;
  end;
end;

function TExtendedListview<T, K>.UpdateData(const aData: T; const aCreateEntryIfNotExists: Boolean): Boolean;
begin
  SortDataItems;
  var lSearchEntry := CreateEntry;
  try
    lSearchEntry.Data := aData;
    var lFoundIndex: Integer;
    if not fDataItemsSortedList.BinarySearch(lSearchEntry, lFoundIndex) then
    begin
      if aCreateEntryIfNotExists then
      begin
        var lNewItem := Add(aData);
        lNewItem.Selected := True;
        lNewItem.MakeVisible(False);
        Exit(True);
      end
      else
      begin
        Exit(False);
      end;
    end;

    var lFoundEntry := fDataItemsSortedList[lFoundIndex];
    fDataItemsAreSorted := fDataIdComparer.Compare(fDataToIdFunc(lFoundEntry.Data), fDataToIdFunc(aData)) = 0;
    lFoundEntry.Data := aData;

    UpdateListItem(lFoundEntry);
    Result := True;
  finally
    lSearchEntry.Free;
  end;
end;

procedure TExtendedListview<T, K>.UpdateListItem(const aEntry: TExtendedListviewEntry<T>);
begin
  if not Assigned(aEntry.ListItem) then
    Exit;

  aEntry.ListItem.Checked := aEntry.Checked;
  fDataToListItemFunc(aEntry.Data, aEntry.ListItem);
end;

function TExtendedListview<T, K>.CreateEntry: TExtendedListviewEntry<T>;
begin
  Result := TExtendedListviewEntry<T>.Create;
end;

{ TExtendedListviewEntry<T> }

procedure TExtendedListviewEntry<T>.SetData(const aValue: T);
begin
  fData := aValue;
end;

{ TExtendedListviewObjectEntry<T> }

destructor TExtendedListviewObjectEntry<T>.Destroy;
begin
  Data.Free;
  inherited;
end;

procedure TExtendedListviewObjectEntry<T>.SetData(const aValue: T);
begin
  if aValue <> Data then
    Exit;

  Data.Free;
  inherited SetData(nil);
  inherited SetData(aValue);
end;

{ TObjectExtendedListview<T, K> }

function TObjecTExtendedListview<T, K>.CreateEntry: TExtendedListviewEntry<T>;
begin
  Result := TExtendedListviewObjectEntry<T>.Create;
end;

end.
