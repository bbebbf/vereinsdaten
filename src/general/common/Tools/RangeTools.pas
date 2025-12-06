unit RangeTools;

interface

uses Nullable;

type
  TRangeTools = class
    class function GetDateRangeString(const aFrom, aTo: INullable<TDate>): string;
  end;

implementation

uses System.SysUtils, System.DateUtils, Vdm.Globals;

{ TRangeTools }

class function TRangeTools.GetDateRangeString(const aFrom, aTo: INullable<TDate>): string;
begin
  Result := '';
  var lFromAvailable := Assigned(aFrom) and aFrom.HasValue;
  var lToAvailable := Assigned(aTo) and aTo.HasValue;

  if lFromAvailable and lToAvailable then
  begin
    if SameDate(aFrom.Value, aTo.Value) then
    begin
      Result := 'am ' + TVdmGlobals.GetDateAsString(aFrom.Value);
    end
    else
    begin
      var lFromFormat := 'dd.mm.yy';
      if YearOf(aFrom.Value) = YearOf(aTo.Value) then
      begin
        lFromFormat := 'dd.mm.';
        if MonthOf(aFrom.Value) = MonthOf(aTo.Value) then
          lFromFormat := 'dd.';
      end;
      Result := 'vom ' + FormatDateTime(lFromFormat, aFrom.Value) + ' bis zum ' +
        TVdmGlobals.GetDateAsString(aTo.Value);
    end;
  end
  else if lFromAvailable then
  begin
    Result := 'ab dem ' + TVdmGlobals.GetDateAsString(aFrom.Value);
  end
  else if lToAvailable then
  begin
    Result := 'bis zum ' + TVdmGlobals.GetDateAsString(aTo.Value);
  end;
end;

end.
