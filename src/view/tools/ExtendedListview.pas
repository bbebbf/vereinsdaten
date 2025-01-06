unit ExtendedListview;

interface

uses System.Generics.Collections, System.Generics.Defaults, Vcl.ComCtrls, InterfacedBase;

type
  TExtendedListviewDataToListItem<T> = reference to procedure(const aData: T; const aListItem: TListItem);
  TExtendedListviewDataPredicate<F, T> = reference to function(const aFilterExpression: F; const aData: T): Boolean;

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
    procedure ClearListItems;
    function AddListItem(const aEntry: TExtendedListviewEntry<T>): TListItem;
    procedure SortDataItems;
    procedure UpdateListItem(const aEntry: TExtendedListviewEntry<T>);
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
    function UpdateData(const aData: T; const aCreateEntryIfNotExists: Boolean = True): Boolean;
    function TryGetListItemData(const aListItem: TListItem; out aData: T): Boolean;
    function TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
    procedure Filter<F>(const aFilterExpression: F; const aPredicate: TExtendedListviewDataPredicate<F, T>);
    property OnEndUpdate: TExtendedListviewOnEndUpdateEvent read fOnEndUpdate write fOnEndUpdate;
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

{ TExtendedListview<T> }

constructor TExtendedListview<T>.Create(const aListview: TListView;
  const aDataToListItemProc: TExtendedListviewDataToListItem<T>; const aDataIdComparer: IComparer<T>);
begin
  inherited Create;
  fListview := aListview;
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
  aEntry.ListItem := Result;
  fListItemToEntryDict.Add(Result, aEntry);
  UpdateListItem(aEntry);
end;

procedure TExtendedListview<T>.ClearListItems;
begin
  fListItemToEntryDict.Clear;
  fListview.Items.Clear;
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
