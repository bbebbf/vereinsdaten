unit VdmGlobals;

interface

type
  TVdmGlobals = class
  public
    class function GetVdmApplicationTitle: string;
    class function GetDateTimePickerNullValue: TDateTime;
  end;


implementation

uses FileTools;

const
  VdmApplicationTitle: string = 'Vereinsdaten-Manager';

{ TVdmGlobals }

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
