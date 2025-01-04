unit ExtendedListview;

interface

uses System.Generics.Collections, System.Generics.Defaults, Vcl.ComCtrls, InterfacedBase;

type
  TExtendedListviewDataToListItem<T> = reference to procedure(const aData: T; const aListItem: TListItem);
  TExtendedListviewDataPredicate<T> = reference to function(const aData: T): Boolean;

  TExtendedListviewEntry<T> = class
  strict private
    fData: T;
  strict protected
    procedure SetData(const aValue: T); virtual;
  public
    property Data: T read fData write SetData;
  end;

  TExtendedListview<T> = class
  strict private
    fListview: TListView;
    fDataItems: TObjectList<TExtendedListviewEntry<T>>;
    fDataToListItemProc: TExtendedListviewDataToListItem<T>;
    fListItemToEntryDict: TDictionary<TListItem, TExtendedListviewEntry<T>>;
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; virtual;
    procedure AddInternal(const aListItem: TListItem; const aEntry: TExtendedListviewEntry<T>); virtual;
    procedure ClearInternal; virtual;
  public
    constructor Create(const aListview: TListView;
      const aDataToListItemProc: TExtendedListviewDataToListItem<T>);
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    function Add(const aData: T): TListItem;
    function TryGetListItemData(const aListItem: TListItem; out aData: T): Boolean;
    function UpdateListItemData(const aListItem: TListItem; const aData: T): Boolean;
  end;

  TMyEqualityComparer<T> = class(TInterfacedBase, IEqualityComparer<TExtendedListviewEntry<T>>)
  strict private
    fEqualityComparer: IEqualityComparer<T>;
    function Equals(const Left, Right: TExtendedListviewEntry<T>): Boolean; reintroduce;
    function GetHashCode(const Value: TExtendedListviewEntry<T>): Integer; reintroduce;
  public
    constructor Create(const aEqualityComparer: IEqualityComparer<T>);
  end;

  TExtendedListviewUniqueData<T> = class(TExtendedListview<T>)
  strict private
    fEntryToListItemDict: TDictionary<TExtendedListviewEntry<T>, TListItem>;
  strict protected
    procedure AddInternal(const aListItem: TListItem; const aEntry: TExtendedListviewEntry<T>); override;
    procedure ClearInternal; override;
  public
    constructor Create(const aListview: TListView; const aDataToListItemProc: TExtendedListviewDataToListItem<T>;
      const aEqualityComparer: IEqualityComparer<T>);
    destructor Destroy; override;
    function TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
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

  TObjectExtendedListviewUniqueData<T: class> = class(TExtendedListviewUniqueData<T>)
  strict protected
    function CreateEntry: TExtendedListviewEntry<T>; override;
  end;

implementation

{ TExtendedListview<T> }

constructor TExtendedListview<T>.Create(const aListview: TListView;
  const aDataToListItemProc: TExtendedListviewDataToListItem<T>);
begin
  inherited Create;
  fListview := aListview;
  fDataToListItemProc := aDataToListItemProc;
  fDataItems := TObjectList<TExtendedListviewEntry<T>>.Create;
  fListItemToEntryDict := TDictionary<TListItem, TExtendedListviewEntry<T>>.Create;
end;

destructor TExtendedListview<T>.Destroy;
begin
  fListItemToEntryDict.Free;
  fDataItems.Free;
  inherited;
end;

function TExtendedListview<T>.Add(const aData: T): TListItem;
begin
  var lEntry := CreateEntry;
  lEntry.Data := aData;
  fDataItems.Add(lEntry);
  Result := fListview.Items.Add;
  AddInternal(Result, lEntry);
  fDataToListItemProc(aData, Result);
end;

procedure TExtendedListview<T>.AddInternal(const aListItem: TListItem; const aEntry: TExtendedListviewEntry<T>);
begin
  fListItemToEntryDict.Add(aListItem, aEntry);
end;

procedure TExtendedListview<T>.Clear;
begin
  ClearInternal;
  fListview.Items.Clear;
  fDataItems.Clear;
end;

procedure TExtendedListview<T>.ClearInternal;
begin
  fListItemToEntryDict.Clear;
end;

procedure TExtendedListview<T>.BeginUpdate;
begin
  fListview.Items.BeginUpdate;
end;

procedure TExtendedListview<T>.EndUpdate;
begin
  fListview.Items.EndUpdate;
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

function TExtendedListview<T>.UpdateListItemData(const aListItem: TListItem; const aData: T): Boolean;
begin
  var lEntry: TExtendedListviewEntry<T>;
  if not fListItemToEntryDict.TryGetValue(aListItem, lEntry) then
    Exit(False);

  lEntry.Data := aData;
  fDataToListItemProc(aData, aListItem);
  Result := True;
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

{ TExtendedListviewUniqueData<T> }

constructor TExtendedListviewUniqueData<T>.Create(const aListview: TListView;
  const aDataToListItemProc: TExtendedListviewDataToListItem<T>; const aEqualityComparer: IEqualityComparer<T>);
begin
  inherited Create(aListview, aDataToListItemProc);
  var lEqualityComparer: IEqualityComparer<TExtendedListviewEntry<T>> :=
    TMyEqualityComparer<T>.Create(aEqualityComparer);
  if Assigned(aEqualityComparer) then
    fEntryToListItemDict := TDictionary<TExtendedListviewEntry<T>, TListItem>.Create(lEqualityComparer)
  else
    fEntryToListItemDict := TDictionary<TExtendedListviewEntry<T>, TListItem>.Create;
end;

destructor TExtendedListviewUniqueData<T>.Destroy;
begin
  fEntryToListItemDict.Free;
  inherited;
end;

function TExtendedListviewUniqueData<T>.TryGetListItem(const aData: T; out aListItem: TListItem): Boolean;
begin
  var lEntry := CreateEntry;
  try
    lEntry.Data := aData;
    Result := fEntryToListItemDict.TryGetValue(lEntry, aListItem);
  finally
    lEntry.Free;
  end;
end;

procedure TExtendedListviewUniqueData<T>.AddInternal(const aListItem: TListItem;
  const aEntry: TExtendedListviewEntry<T>);
begin
  inherited;
  fEntryToListItemDict.AddOrSetValue(aEntry, aListItem);
end;

procedure TExtendedListviewUniqueData<T>.ClearInternal;
begin
  inherited;
  fEntryToListItemDict.Clear;
end;

{ TMyEqualityComparer<T> }

constructor TMyEqualityComparer<T>.Create(const aEqualityComparer: IEqualityComparer<T>);
begin
  inherited Create;
  fEqualityComparer := aEqualityComparer;
end;

function TMyEqualityComparer<T>.Equals(const Left, Right: TExtendedListviewEntry<T>): Boolean;
begin
  Result := fEqualityComparer.Equals(Left.Data, Right.Data);
end;

function TMyEqualityComparer<T>.GetHashCode(const Value: TExtendedListviewEntry<T>): Integer;
begin
  Result := fEqualityComparer.GetHashCode(Value.Data);
end;

{ TObjectExtendedListview<T> }

function TObjectExtendedListview<T>.CreateEntry: TExtendedListviewEntry<T>;
begin
  Result := TExtendedListviewObjectEntry<T>.Create;
end;

{ TObjectExtendedListviewUniqueData<T> }

function TObjectExtendedListviewUniqueData<T>.CreateEntry: TExtendedListviewEntry<T>;
begin
  Result := TExtendedListviewObjectEntry<T>.Create;
end;

end.
