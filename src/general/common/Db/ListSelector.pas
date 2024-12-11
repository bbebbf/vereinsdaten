unit ListSelector;

interface

uses System.Generics.Collections, SqlConnection, FilterSelect, SelectListFilter;

type
  TListSelector<T; F: record> = class(TFilterSelect<T, F>)
  strict private
    fItems: TList<T>;
    procedure OnListNotify(Sender: TObject; const Item: T; Action: TCollectionNotification);
    function GetItems: TList<T>;
  strict protected
    procedure FilterChanged; override;
    procedure ListEnumBegin; override;
    procedure ListEnumProcessItem(const aItem: T); override;
    procedure Notify(const Item: T; Action: TCollectionNotification); virtual;
  public
    destructor Destroy; override;
    procedure InvalidateItems;
    property Items: TList<T> read GetItems;
  end;

  TObjectListSelector<T: class; F: record> = class(TListSelector<T, F>)
  protected
    procedure Notify(const Item: T; Action: TCollectionNotification); override;
  end;

implementation

uses System.SysUtils;

{ TListSelector<T, F> }

destructor TListSelector<T, F>.Destroy;
begin
  fItems.Free;
  inherited;
end;

function TListSelector<T, F>.GetItems: TList<T>;
begin
  if Assigned(fItems) then
    Exit(fItems);

  ApplyFilter;
  Result := fItems;
end;

procedure TListSelector<T, F>.InvalidateItems;
begin
  FreeAndNil(fItems);
end;

procedure TListSelector<T, F>.Notify(const Item: T; Action: TCollectionNotification);
begin

end;

procedure TListSelector<T, F>.OnListNotify(Sender: TObject; const Item: T; Action: TCollectionNotification);
begin
  Notify(Item, Action);
end;

procedure TListSelector<T, F>.FilterChanged;
begin
  inherited;
  InvalidateItems;
end;

procedure TListSelector<T, F>.ListEnumBegin;
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

procedure TListSelector<T, F>.ListEnumProcessItem(const aItem: T);
begin
  inherited;
  fItems.Add(aItem);
end;

{ TObjectListSelector<T, F> }

procedure TObjectListSelector<T, F>.Notify(const Item: T; Action: TCollectionNotification);
begin
  inherited;
  if Action = cnRemoved then
    Item.Free;
end;

end.
