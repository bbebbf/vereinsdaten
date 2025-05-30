unit ListSelector;

interface

uses System.Generics.Collections, SqlConnection, FilterSelect, SelectListFilter;

type
  TListSelector<T; FSelect, FLoop: record> = class(TFilterSelect<T, FSelect, FLoop>)
  strict private
    fItems: TList<T>;
    procedure OnListNotify(Sender: TObject; const Item: T; Action: TCollectionNotification);
    function GetItems: TList<T>;
  strict protected
    procedure FilterChanged; override;
    procedure ListEnumBegin; override;
    procedure ListEnumProcessItem(const aItem: T; const aSqlResult: ISqlResult); override;
    procedure Notify(const Item: T; Action: TCollectionNotification); virtual;
  public
    destructor Destroy; override;
    procedure InvalidateItems;
    property Items: TList<T> read GetItems;
  end;

  TObjectListSelector<T: class; FSelect, FLoop: record> = class(TListSelector<T, FSelect, FLoop>)
  protected
    procedure Notify(const Item: T; Action: TCollectionNotification); override;
  end;

implementation

uses System.SysUtils;

{ TListSelector<T, FSelect, FLoop> }

destructor TListSelector<T, FSelect, FLoop>.Destroy;
begin
  fItems.Free;
  inherited;
end;

function TListSelector<T, FSelect, FLoop>.GetItems: TList<T>;
begin
  if Assigned(fItems) then
    Exit(fItems);

  ApplyFilter;
  Result := fItems;
end;

procedure TListSelector<T, FSelect, FLoop>.InvalidateItems;
begin
  FreeAndNil(fItems);
end;

procedure TListSelector<T, FSelect, FLoop>.Notify(const Item: T; Action: TCollectionNotification);
begin

end;

procedure TListSelector<T, FSelect, FLoop>.OnListNotify(Sender: TObject; const Item: T; Action: TCollectionNotification);
begin
  Notify(Item, Action);
end;

procedure TListSelector<T, FSelect, FLoop>.FilterChanged;
begin
  inherited;
  InvalidateItems;
end;

procedure TListSelector<T, FSelect, FLoop>.ListEnumBegin;
begin
  inherited;
  if Assigned(fItems) then
  begin
    fItems.Clear;
  end
  else
  begin
    fItems := TList<T>.Create;
    fItems.OnNotify := OnListNotify;
  end;
end;

procedure TListSelector<T, FSelect, FLoop>.ListEnumProcessItem(const aItem: T; const aSqlResult: ISqlResult);
begin
  inherited;
  fItems.Add(aItem);
end;

{ TObjectListSelector<T, FSelect, FLoop> }

procedure TObjectListSelector<T, FSelect, FLoop>.Notify(const Item: T; Action: TCollectionNotification);
begin
  inherited;
  if Action = cnRemoved then
    Item.Free;
end;

end.
