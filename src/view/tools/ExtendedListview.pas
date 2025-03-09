unit ExtendedListview;

interface

uses System.Generics.Collections, System.Generics.Defaults, Vcl.ComCtrls, InterfacedBase;

type
  TExtendedListviewDataToListItem<T> = reference to procedure(const aData: T; const aListItem: TListItem);
  TExtendedListviewDataPredicate<F, T> = reference to function(const aFilterExpression: F; const aData: T): Boolean;
  TExtendedListviewCompareColumn<T> = reference to procedure(const aData1, aData2: T;
    const aColumnIndex: Integer; var aCompareResult: Integer; var aHandled: Boolean);

  TExtendedListviewOnEndUpdateEvent = procedure(Sender: TObject; const aTotalItemCount, aVisibleItemCount: Integer) of object;

  TExtendedListviewEntry<T> = class
  strict private
    fData: T;
    fListItem: TListItem;
  strict protected
    procedure SetData(const aValue: T); virtual;
  public
    property Data: T read fData write SetData;
    property ListItem: TListItem read fListItem write fListItem;
  end;

  TExtendedListview<T> = class
  strict private
    fListview: TListView;
    fDataItemsOwner: TObjectList<TExtendedListviewEntry<T>>;
    fDataItemsSortedList: TList<TExtendedListviewEntry<T>>;
    fDataItemsAreSorted: Boolean;
    fDataToListItemProc: TExtendedListviewDataToListItem<T>;
    fDataIdComparer: IComparer<T>;
    fListItemToEntryDict: TDictionary<TListItem, TExtendedListviewEntry<T>>;
    fOnEndUpdate: TExtendedListviewOnEndUpdateEvent;
    fColumnClickedColumn: TListColumn;
    fColumnClickedSortDescending: Boolean;
    fOnCompareColumn: TExtendedListviewCompareColumn<T>;
    fImageIndexSortUp: Integer;
    fImageIndexSortDown: Integer;
    procedure ClearListItems;
    function AddListItem(const aEntry: TExtendedListviewEntry<T>): TListItem;
    procedure SortDataItems;
    procedure UpdateListItem(const aEntry: TExtendedListviewEntry<T>);
    procedure OnListviewColumnClick(Sender: TObject; Column: TListColumn);
    procedure LVCompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer; var Compare: Integer);
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; virtual;
  public
    constructor Create(const aListview: TListView;
      const aDataToListItemProc: TExtendedListviewDataToListItem<T>;
      const aDataIdComparer: IComparer<T>);
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
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
  end;

  TExtendedListviewObjectEntry<T: class> = class(TExtendedListviewEntry<T>)
  strict protected
    procedure SetData(const aValue: T); override;
  public
    destructor Destroy; override;
  end;

  TObjectExtendedListview<T: class> = class(TExtendedListview<T>)
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; override;
  end;

implementation

uses System.SysUtils, Winapi.Windows;

{ TExtendedListview<T> }

constructor TExtendedListview<T>.Create(const aListview: TListView;
  const aDataToListItemProc: TExtendedListviewDataToListItem<T>; const aDataIdComparer: IComparer<T>);
begin
  inherited Create;
  fListview := aListview;
  fListview.OnColumnClick := OnListviewColumnClick;
  fListview.OnCompare := LVCompareEvent;
  fDataToListItemProc := aDataToListItemProc;
  fDataItemsOwner := TObjectList<TExtendedListviewEntry<T>>.Create;

  fDataIdComparer := aDataIdComparer;
  if not Assigned(fDataIdComparer) then
    fDataIdComparer := TComparer<T>.Default;

  var lEntryComparer: IComparer<TExtendedListviewEntry<T>> := TComparer<TExtendedListviewEntry<T>>.Construct(
      function(const aLeft, aRight: TExtendedListviewEntry<T>): Integer
      begin
        Result := fDataIdComparer.Compare(aLeft.Data, aRight.Data);
      end
    );
  fDataItemsSortedList := TList<TExtendedListviewEntry<T>>.Create(lEntryComparer);

  fListItemToEntryDict := TDictionary<TListItem, TExtendedListviewEntry<T>>.Create;
  fDataItemsAreSorted := True;
  fImageIndexSortUp := -1;
  fImageIndexSortDown := -1;
end;

destructor TExtendedListview<T>.Destroy;
begin
  fListItemToEntryDict.Free;
  fDataItemsSortedList.Free;
  fDataItemsOwner.Free;
  inherited;
end;

function TExtendedListview<T>.Add(const aData: T): TListItem;
begin
  var lEntry := CreateEntry;
  lEntry.Data := aData;
  fDataItemsOwner.Add(lEntry);
  fDataItemsSortedList.Add(lEntry);
  Result := AddListItem(lEntry);
  fDataItemsAreSorted := False;
end;

procedure TExtendedListview<T>.Clear;
begin
  ClearListItems;
  fDataItemsSortedList.Clear;
  fDataItemsOwner.Clear;
  fDataItemsAreSorted := True;
end;

function TExtendedListview<T>.AddListItem(const aEntry: TExtendedListviewEntry<T>): TListItem;
begin
  Result := fListview.Items.Add;
  Result.ImageIndex := -1;
  aEntry.ListItem := Result;
  fListItemToEntryDict.Add(Result, aEntry);
  UpdateListItem(aEntry);
end;

procedure TExtendedListview<T>.ClearListItems;
begin
  fListItemToEntryDict.Clear;
  fListview.Items.Clear;
  for var i := 0 to fListview.Columns.Count - 1 do
    fListview.Columns[i].ImageIndex := -1;
end;

procedure TExtendedListview<T>.BeginUpdate;
begin
  fListview.Items.BeginUpdate;
end;

procedure TExtendedListview<T>.EndUpdate;
begin
  if Assigned(fOnEndUpdate) then
    fOnEndUpdate(Self, fDataItemsOwner.Count, fListview.Items.Count);
  fListview.Items.EndUpdate;
end;

procedure TExtendedListview<T>.Filter<F>(const aFilterExpression: F;
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

procedure TExtendedListview<T>.InvalidateListItems;
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

procedure TExtendedListview<T>.LVCompareEvent(Sender: TObject; Item1, Item2: TListItem; Data: Integer;
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

procedure TExtendedListview<T>.OnListviewColumnClick(Sender: TObject; Column: TListColumn);
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

procedure TExtendedListview<T>.SortDataItems;
begin
  if fDataItemsAreSorted then
    Exit;
  fDataItemsSortedList.Sort;
  fDataItemsAreSorted := True;
end;

function TExtendedListview<T>.TryGetListItemData(const aListItem: TListItem; out aData: T): Boolean;
begin
  aData := default(T);
  var lEntry: TExtendedListviewEntry<T>;
  if not fListItemToEntryDict.TryGetValue(aListItem, lEntry) then
    Exit(False);

  aData := lEntry.Data;
  Result := True;
end;

function TExtendedListview<T>.TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
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

function TExtendedListview<T>.Delete(const aData: T): Boolean;
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

function TExtendedListview<T>.UpdateData(const aData: T; const aCreateEntryIfNotExists: Boolean): Boolean;
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
    fDataItemsAreSorted := fDataIdComparer.Compare(lFoundEntry.Data, aData) = 0;
    lFoundEntry.Data := aData;

    UpdateListItem(lFoundEntry);
    Result := True;
  finally
    lSearchEntry.Free;
  end;
end;

procedure TExtendedListview<T>.UpdateListItem(const aEntry: TExtendedListviewEntry<T>);
begin
  if Assigned(aEntry.ListItem) then
    fDataToListItemProc(aEntry.Data, aEntry.ListItem);
end;

function TExtendedListview<T>.CreateEntry: TExtendedListviewEntry<T>;
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

{ TObjectExtendedListview<T> }

function TObjectExtendedListview<T>.CreateEntry: TExtendedListviewEntry<T>;
begin
  Result := TExtendedListviewObjectEntry<T>.Create;
end;

end.
