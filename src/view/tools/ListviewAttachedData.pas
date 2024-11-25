unit ListviewAttachedData;

interface

uses System.Generics.Collections, Vcl.ComCtrls;

type
  TListviewAttachedDataEntry<TKey, TExtraData> = class
  strict private
    fKey: TKey;
    fExtraData: TExtraData;
  public
    constructor Create(const aKey: TKey; const aExtraData: TExtraData);
    property Key: TKey read fKey;
    property ExtraData: TExtraData read fExtraData;
  end;

  TListviewAttachedData<TKey, TExtraData> = class
  strict private
    fListView: TCustomListView;
    fItemDict: TObjectDictionary<TListItem, TListviewAttachedDataEntry<TKey, TExtraData>>;
    fKeyDict: TDictionary<TKey, TListItem>;
    procedure InsertInto(const aItem: TListItem; const aKey: TKey; const aExtraData: TExtraData);
    function RemoveFrom(const aItem: TListItem): Boolean;
  public
    constructor Create(const aListView: TCustomListView);
    destructor Destroy; override;
    procedure Clear;
    function AddItem(const aKey: TKey): TListItem; overload;
    function AddItem(const aKey: TKey; const aExtraData: TExtraData): TListItem; overload;
    function UpdateItem(const aItem: TListItem; const aKey: TKey): Boolean; overload;
    function UpdateItem(const aItem: TListItem; const aKey: TKey; const aExtraData: TExtraData): Boolean; overload;
    function TryGetData(const aItem: TListItem; out aData: TListviewAttachedDataEntry<TKey, TExtraData>): Boolean;
    function TryGetKey(const aItem: TListItem; out aKey: TKey): Boolean;
    function TryGetExtraData(const aItem: TListItem; out aExtraData: TExtraData): Boolean;
    function TryGetItem(const aKey: TKey; out aItem: TListItem): Boolean;
  end;

implementation

{ TListviewAttachedData<TKey, TExtraData> }

constructor TListviewAttachedData<TKey, TExtraData>.Create(const aListView: TCustomListView);
begin
  inherited Create;
  fListView := aListView;
  fItemDict := TObjectDictionary<TListItem, TListviewAttachedDataEntry<TKey, TExtraData>>.Create([doOwnsValues]);
  fKeyDict := TDictionary<TKey, TListItem>.Create;
end;

destructor TListviewAttachedData<TKey, TExtraData>.Destroy;
begin
  fKeyDict.Free;
  fItemDict.Free;
  inherited;
end;

function TListviewAttachedData<TKey, TExtraData>.AddItem(const aKey: TKey): TListItem;
begin
  Result := AddItem(aKey, default(TExtraData));
end;

function TListviewAttachedData<TKey, TExtraData>.AddItem(const aKey: TKey; const aExtraData: TExtraData): TListItem;
begin
  Result := fListView.Items.Add;
  InsertInto(Result, aKey, aExtraData);
end;

procedure TListviewAttachedData<TKey, TExtraData>.InsertInto(const aItem: TListItem; const aKey: TKey;
  const aExtraData: TExtraData);
begin
  fItemDict.Add(aItem, TListviewAttachedDataEntry<TKey, TExtraData>.Create(aKey, aExtraData));
  fKeyDict.Add(aKey, aItem);
end;

function TListviewAttachedData<TKey, TExtraData>.RemoveFrom(const aItem: TListItem): Boolean;
begin
  Result := False;
  var lData: TListviewAttachedDataEntry<TKey, TExtraData>;
  if fItemDict.TryGetValue(aItem, lData) then
  begin
    Result := True;
    fKeyDict.Remove(lData.Key);
    fItemDict.Remove(aItem);
  end;
end;

procedure TListviewAttachedData<TKey, TExtraData>.Clear;
begin
  fKeyDict.Clear;
  fItemDict.Clear;
  fListView.Items.Clear;
end;

function TListviewAttachedData<TKey, TExtraData>.TryGetData(const aItem: TListItem;
  out aData: TListviewAttachedDataEntry<TKey, TExtraData>): Boolean;
begin
  Result := fItemDict.TryGetValue(aItem, aData);
end;

function TListviewAttachedData<TKey, TExtraData>.TryGetExtraData(const aItem: TListItem;
  out aExtraData: TExtraData): Boolean;
begin
  Result := False;
  var lData: TListviewAttachedDataEntry<TKey, TExtraData>;
  if TryGetData(aItem, lData) then
  begin
    Result := True;
    aExtraData := lData.ExtraData;
  end;
end;

function TListviewAttachedData<TKey, TExtraData>.TryGetItem(const aKey: TKey; out aItem: TListItem): Boolean;
begin
  Result := fKeyDict.TryGetValue(aKey, aItem);
end;

function TListviewAttachedData<TKey, TExtraData>.TryGetKey(const aItem: TListItem; out aKey: TKey): Boolean;
begin
  Result := False;
  var lData: TListviewAttachedDataEntry<TKey, TExtraData>;
  if TryGetData(aItem, lData) then
  begin
    Result := True;
    aKey := lData.Key;
  end;
end;

function TListviewAttachedData<TKey, TExtraData>.UpdateItem(const aItem: TListItem; const aKey: TKey;
  const aExtraData: TExtraData): Boolean;
begin
  Result := False;
  if RemoveFrom(aItem) then
  begin
    Result := True;
    InsertInto(aItem, aKey, aExtraData);
  end;
end;

function TListviewAttachedData<TKey, TExtraData>.UpdateItem(const aItem: TListItem; const aKey: TKey): Boolean;
begin
  Result := UpdateItem(aItem, aKey, default(TExtraData));
end;

{ TListviewAttachedDataEntry<TKey, TExtraData> }

constructor TListviewAttachedDataEntry<TKey, TExtraData>.Create(const aKey: TKey; const aExtraData: TExtraData);
begin
  inherited Create;
  fKey := aKey;
  fExtraData := aExtraData;
end;

end.
