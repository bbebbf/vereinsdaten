unit ListCrudCommands;

interface

uses System.SysUtils, System.Generics.Collections, SqlConnection, FilterSelect, SelectListFilter,
  ListEnumerator;

type
  TListEntryCrudState = (Unchanged, Updated, New, ToBeDeleted);

  TListEntry<T> = class
  strict private
    fData: T;
    fState: TListEntryCrudState;
  public
    constructor Create(const aData: T);
    constructor CreateNew(const aData: T);
    procedure Updated;
    procedure Resetted;
    procedure ToBeDeleted;
    property Data: T read fData;
    property State: TListEntryCrudState read fState;
  end;

  TObjectListEntry<T: class> = class(TListEntry<T>)
  public
    destructor Destroy; override;
  end;


  TListCrudCommands<TS; TD; F: record> = class(TFilterSelect<TS, F>)
  strict private
    fItems: TList<TListEntry<TD>>;
    fGetItemFromSourceCallback: TFunc<TS, TD>;
    fTargetEnumerator: IListEnumerator<TD>;
  strict protected
    function CreateListEntry(const aItem: TD): TListEntry<TD>; virtual;
    procedure FilterChanged; override;
    procedure ListEnumBegin; override;
    procedure ListEnumProcessItem(const aItem: TS); override;
    procedure ListEnumEnd; override;
  public
    constructor Create(const aConnection: ISqlConnection;
      const aConfig: ISelectListFilter<TS, F>;
      const aGetItemFromSourceCallback: TFunc<TS, TD>);
    destructor Destroy; override;
    procedure Reload;
    property TargetEnumerator: IListEnumerator<TD> read fTargetEnumerator write fTargetEnumerator;
    property Items: TList<TListEntry<TD>> read fItems;
  end;

  TObjectListCrudCommands<TS; TD: class; F: record> = class(TListCrudCommands<TS, TD, F>)
  strict protected
    function CreateListEntry(const aItem: TD): TListEntry<TD>; override;
  end;

implementation

{ TListCrudCommands<TS, TD, F> }

constructor TListCrudCommands<TS, TD, F>.Create(const aConnection: ISqlConnection;
  const aConfig: ISelectListFilter<TS, F>; const aGetItemFromSourceCallback: TFunc<TS, TD>);
begin
  inherited Create(aConnection, aConfig);
  fGetItemFromSourceCallback := aGetItemFromSourceCallback;
end;

destructor TListCrudCommands<TS, TD, F>.Destroy;
begin
  fItems.Free;
  inherited;
end;

procedure TListCrudCommands<TS, TD, F>.FilterChanged;
begin
  inherited;
  ApplyFilter;
end;

procedure TListCrudCommands<TS, TD, F>.ListEnumBegin;
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

procedure TListCrudCommands<TS, TD, F>.ListEnumEnd;
begin
  inherited;
  if Assigned(fTargetEnumerator) then
    fTargetEnumerator.ListEnumEnd;
end;

procedure TListCrudCommands<TS, TD, F>.ListEnumProcessItem(const aItem: TS);
begin
  inherited;
  var lTargetItem := fGetItemFromSourceCallback(aItem);
  var lEntry := CreateListEntry(lTargetItem);
  fItems.Add(lEntry);
  if Assigned(fTargetEnumerator) then
    fTargetEnumerator.ListEnumProcessItem(lTargetItem);
end;

function TListCrudCommands<TS, TD, F>.CreateListEntry(const aItem: TD): TListEntry<TD>;
begin
  Result := TListEntry<TD>.Create(aItem);
end;

procedure TListCrudCommands<TS, TD, F>.Reload;
begin
  FreeAndNil(fItems);
  ApplyFilter;
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

procedure TListEntry<T>.ToBeDeleted;
begin
  if fState = TListEntryCrudState.New then
    fState := TListEntryCrudState.Unchanged
  else
    fState := TListEntryCrudState.ToBeDeleted;
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

{ TObjectListCrudCommands<TS, TD, F> }

function TObjectListCrudCommands<TS, TD, F>.CreateListEntry(const aItem: TD): TListEntry<TD>;
begin
  Result := TObjectListEntry<TD>.Create(aItem);
end;

end.
