unit unPersonMemberOf;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.ExtCtrls,
  ListviewAttachedData, DtoMember, DtoMemberAggregated, PersonMemberOfUI, MemberOfBusinessIntf, Vcl.StdCtrls;

type
  TMemberOfListItemData = record
    Active: Boolean;
  end;

  TfraPersonMemberOf = class(TFrame, IPersonMemberOfUI)
    lvMemberOf: TListView;
    pnCommands: TPanel;
    cbShowInactiveMemberOfs: TCheckBox;
    procedure lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
      var DefaultDraw: Boolean);
  private
    fBusinessIntf: IMemberOfBusinessIntf;
    fMemberOfListviewAttachedData: TListviewAttachedData<UInt32, TMemberOfListItemData>;
    fAvailableUnits: TStringList;
    fAvailableRoles: TStringList;
    procedure Initialize(const aCommands: IMemberOfBusinessIntf);
    procedure ListEnumBegin;
    procedure ListEnumProcessItem(const aItem: TDtoMemberAggregated);
    procedure ListEnumEnd;

    procedure MemberEntryToListItem(const aMember: TDtoMemberAggregated; const aItem: TListItem);
    function GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

uses VdmGlobals;

{ TfraPersonMemberOf }

constructor TfraPersonMemberOf.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  fMemberOfListviewAttachedData := TListviewAttachedData<UInt32, TMemberOfListItemData>.Create(lvMemberOf);
  fAvailableUnits := TStringList.Create;
  fAvailableRoles := TStringList.Create;
end;

destructor TfraPersonMemberOf.Destroy;
begin
  fAvailableRoles.Free;
  fAvailableUnits.Free;
  fMemberOfListviewAttachedData.Free;
  inherited;
end;

procedure TfraPersonMemberOf.Initialize(const aCommands: IMemberOfBusinessIntf);
begin
  fBusinessIntf := aCommands;
  fBusinessIntf.LoadAvailableUnits(fAvailableUnits);
  fBusinessIntf.LoadAvailableRoles(fAvailableRoles);
end;

procedure TfraPersonMemberOf.ListEnumBegin;
begin
  fMemberOfListviewAttachedData.Clear;
end;

procedure TfraPersonMemberOf.ListEnumEnd;
begin

end;

procedure TfraPersonMemberOf.ListEnumProcessItem(const aItem: TDtoMemberAggregated);
begin
  MemberEntryToListItem(aItem, nil);
end;

procedure TfraPersonMemberOf.lvMemberOfCustomDrawItem(Sender: TCustomListView; Item: TListItem; State: TCustomDrawState;
  var DefaultDraw: Boolean);
begin
  DefaultDraw := True;
  var lMemberOfListItemData := default(TMemberOfListItemData);
  if fMemberOfListviewAttachedData.TryGetExtraData(Item, lMemberOfListItemData) then
  begin
    if not lMemberOfListItemData.Active then
      Sender.Canvas.Font.Color := clLtGray;
  end;
end;

procedure TfraPersonMemberOf.MemberEntryToListItem(const aMember: TDtoMemberAggregated; const aItem: TListItem);
begin
  var lMemberOfListItemData := default(TMemberOfListItemData);
  lMemberOfListItemData.Active := aMember.Member.Active;
  var lItem := aItem;
  if Assigned(lItem) then
  begin
    fMemberOfListviewAttachedData.UpdateItem(aItem, aMember.Id, lMemberOfListItemData);
  end
  else
  begin
    lItem := fMemberOfListviewAttachedData.AddItem(aMember.Id, lMemberOfListItemData);
    lItem.SubItems.Add('');
    lItem.SubItems.Add('');
    lItem.SubItems.Add('');
    lItem.SubItems.Add('');
  end;
  lItem.Caption := GetStringByIndex(fAvailableUnits, fBusinessIntf.GetUnitMapperIndex(aMember.Member.UnitId));
  lItem.SubItems[0] := GetStringByIndex(fAvailableRoles, fBusinessIntf.GetRoleMapperIndex(aMember.Member.RoleId));
  lItem.SubItems[1] := TVdmGlobals.GetDateAsString(aMember.Member.ActiveSince);
  if aMember.Member.Active then
    lItem.SubItems[2] := 'A'
  else
    lItem.SubItems[2] := 'I';
  lItem.SubItems[3] := TVdmGlobals.GetDateAsString(aMember.Member.ActiveUntil);
end;

function TfraPersonMemberOf.GetStringByIndex(const aStrings: TStrings; const aIndex: Integer): string;
begin
  if (0 <= aIndex) and (aIndex < aStrings.Count) then
    Result := aStrings[aIndex]
  else
    Result := '';
end;

end.
