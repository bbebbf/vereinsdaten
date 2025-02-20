unit Vdm.Globals;

interface

uses ListCrudCommands.Types, System.UITypes;

type
  TVdmGlobals = class
  public
    class function GetVdmApplicationTitle: string;
    class function GetDateTimePickerNullValue: TDateTime;
    class function GetDateAsString(const aValue: TDateTime): string;
    class function GetDateTimeAsString(const aValue: TDateTime): string;
    class function GetTimeStampAsString(const aValue: TDateTime): string;
    class function TryGetColorForCrudState(const aState: TListEntryCrudState; out aColor: TColor): Boolean;
    class function GetInactiveColor: TColor;
    class function GetActiveStateAsString(const aState: Boolean): string;
    class function MinusOneToZero(const aIndex: Integer): Integer;
    class function CompareId(const aLeft, aRight: UInt32): Integer;
    class function GetRoleSortingSqlOrderBy(const aRoleTableAlias: string = ''): string;
    class function GetRoleSortingNullWeight: UInt8;
  end;

implementation

uses System.SysUtils, FileTools;

const
  VdmApplicationTitle: string = 'Vereinsdaten-Manager';
  RoleSortingNoValueWeight: UInt8 = 100;

{ TVdmGlobals }

class function TVdmGlobals.CompareId(const aLeft, aRight: UInt32): Integer;
begin
  if aLeft < aRight then
    Result := -1
  else if aLeft > aRight then
    Result := 1
  else
    Result := 0;
end;

class function TVdmGlobals.GetActiveStateAsString(const aState: Boolean): string;
begin
  if aState then
    Result := 'Aktiv'
  else
    Result := 'Inaktiv';
end;

class function TVdmGlobals.GetDateAsString(const aValue: TDateTime): string;
begin
  if aValue > GetDateTimePickerNullValue then
    Result := FormatDateTime('dd.mm.yyyy', aValue)
  else
    Result := '';
end;

class function TVdmGlobals.GetDateTimeAsString(const aValue: TDateTime): string;
begin
  if aValue > GetDateTimePickerNullValue then
    Result := FormatDateTime('dd.mm.yyyy HH:nn', aValue)
  else
    Result := '';
end;

class function TVdmGlobals.GetTimeStampAsString(const aValue: TDateTime): string;
begin
  if aValue > GetDateTimePickerNullValue then
    Result := FormatDateTime('dd.mm.yyyy HH:nn:ss', aValue)
  else
    Result := '';
end;

class function TVdmGlobals.GetDateTimePickerNullValue: TDateTime;
begin
  Result := 1;
end;

class function TVdmGlobals.GetInactiveColor: TColor;
begin
  Result := TColorRec.Silver;
end;

class function TVdmGlobals.GetRoleSortingNullWeight: UInt8;
begin
  Result := RoleSortingNoValueWeight;
end;

class function TVdmGlobals.GetRoleSortingSqlOrderBy(const aRoleTableAlias: string): string;
begin
  var lTableAlias := '';
  if Length(aRoleTableAlias) > 0 then
    lTableAlias := aRoleTableAlias + '.';
  Result := 'IFNULL(' + lTableAlias + 'role_sorting, ' + IntToStr(RoleSortingNoValueWeight) + ')';
end;

class function TVdmGlobals.GetVdmApplicationTitle: string;
begin
  Result := VdmApplicationTitle;
  var lFileVersion: TFileVersionRecord;
  if TFileTools.GetFileVersion(ParamStr(0), lFileVersion) then
    Result := Result + ' ' + lFileVersion.ToString;
end;

class function TVdmGlobals.MinusOneToZero(const aIndex: Integer): Integer;
begin
  if aIndex = -1 then
    Result := 0
  else
    Result := aIndex;
end;

class function TVdmGlobals.TryGetColorForCrudState(const aState: TListEntryCrudState; out aColor: TColor): Boolean;
begin
  Result := True;
  case aState of
    TListEntryCrudState.Updated:
      aColor := TColorRec.Coral;
    TListEntryCrudState.New:
      aColor := TColorRec.Blue;
    TListEntryCrudState.NewDeleted:
      aColor := TColorRec.Deepskyblue;
    TListEntryCrudState.ToBeDeleted:
      aColor := TColorRec.Red;
    else
      Result := False;
  end;
end;

end.
