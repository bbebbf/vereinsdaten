unit VdmGlobals;

interface

type
  TVdmGlobals = class
  public
    class function GetVdmApplicationTitle: string;
    class function GetDateTimePickerNullValue: TDateTime;
    class function GetDateAsString(const aValue: TDateTime): string;
    class function GetDateTimeAsString(const aValue: TDateTime): string;
  end;

implementation

uses System.SysUtils, FileTools;

const
  VdmApplicationTitle: string = 'Vereinsdaten-Manager';

{ TVdmGlobals }

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

class function TVdmGlobals.GetDateTimePickerNullValue: TDateTime;
begin
  Result := 1;
end;

class function TVdmGlobals.GetVdmApplicationTitle: string;
begin
  Result := VdmApplicationTitle;
  var lFileVersion: TFileVersionRecord;
  if TFileTools.GetFileVersion(ParamStr(0), lFileVersion) then
    Result := Result + ' ' + lFileVersion.ToString;
end;

end.
