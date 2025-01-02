unit ExtendedListview;

interface

uses System.Generics.Collections, Vcl.ComCtrls;

type
  TExtendedListviewItemToListItem<T> = reference to procedure(const aItem: T; const aListItem: TListItem);

  TExtendedListviewItemPredicate<T> = reference to function(const aItem: T): Boolean;

  TExtendedListview<T> = class
  strict private
    fListview: TListView;
    fItemToListItemProc: TExtendedListviewItemToListItem<T>;
    fItems: TList<TPair<T, TListItem>>;
    procedure ItemsNotify(Sender: TObject; const Item: TPair<T, TListItem>; Action: TCollectionNotification);
  strict protected
    procedure ReleaseItem(var aItem: T); virtual;
  public
    constructor Create(const aListview: TListView;
      const aItemToListItemProc: TExtendedListviewItemToListItem<T>);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Clear;
    procedure Add(const aItem: T);
    destructor Destroy; override;
  end;

  TObjectExtendedListview<T: class> = class(TExtendedListview<T>)
  strict protected
    procedure ReleaseItem(var aItem: T); override;
  end;

implementation

{ TExtendedListview<T> }

constructor TExtendedListview<T>.Create(const aListview: TListView;
  const aItemToListItemProc: TExtendedListviewItemToListItem<T>);
begin
  inherited Create;
  fListview := aListview;
  fItemToListItemProc := aItemToListItemProc;
  fItems := TList<TPair<T, TListItem>>.Create;
  fItems.OnNotify := ItemsNotify;
end;

destructor TExtendedListview<T>.Destroy;
begin
  fItems.Free;
  inherited;
end;

procedure TExtendedListview<T>.Add(const aItem: T);
begin
  var lListItem := fListview.Items.Add;
  fItemToListItemProc(aItem, lListItem);
  fItems.Add(TPair<T, TListItem>.Create(aItem, lListItem));
end;

procedure TExtendedListview<T>.Clear;
begin
  fListview.Items.Clear;
  fItems.Clear;
end;

procedure TExtendedListview<T>.BeginUpdate;
begin
  fListview.Items.BeginUpdate;
end;

procedure TExtendedListview<T>.EndUpdate;
begin
  fListview.Items.EndUpdate;
end;

procedure TExtendedListview<T>.ItemsNotify(Sender: TObject; const Item: TPair<T, TListItem>; Action: TCollectionNotification);
begin
  if Action = cnRemoved then
  begin
    var lKey := Item.Key;
    ReleaseItem(lKey);
  end;
end;

procedure TExtendedListview<T>.ReleaseItem(var aItem: T);
begin

end;

{ TObjectExtendedListview<T> }

procedure TObjectExtendedListview<T>.ReleaseItem(var aItem: T);
begin
  inherited;
  aItem.Free;
end;

end.
