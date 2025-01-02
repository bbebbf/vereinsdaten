unit FileTools;

interface

type
  TFileVersionRecord = record
    MajorVersion: Word;
    MinorVersion: Word;
    EditionVersion: Word;
    CompilationVersion: Word;
    function ToString(const aFull: Boolean = False): string;
  end;

  TFileTools = class
  public
    class function GetFileVersion(const aPath: string; out aVersion: TFileVersionRecord): Boolean;
  end;

implementation

uses System.SysUtils, Winapi.Windows;

{ TFileTools }

class function TFileTools.GetFileVersion(const aPath: string; out aVersion: TFileVersionRecord): Boolean;
var
  lpVerInfo: Pointer;
  rVerValue: PVSFixedFileInfo;
  dwInfoSize: Cardinal;
  dwValueSize: Cardinal;
  dwDummy: Cardinal;
  lpstrPath: PChar;
begin
  Result := False;
  aVersion := default(TFileVersionRecord);

  lpstrPath := PChar(aPath);
  dwInfoSize := GetFileVersionInfoSize(lpstrPath, dwDummy);
  if dwInfoSize = 0 then
  begin
    Exit;
  end;

  GetMem(lpVerInfo, dwInfoSize);
  try
    if not GetFileVersionInfo(lpstrPath, 0, dwInfoSize, lpVerInfo) then
    begin
      Exit;
    end;
    if not VerQueryValue(lpVerInfo, '', Pointer(rVerValue), dwValueSize) then
    begin
      Exit;
    end;
    with rVerValue^ do
    begin
      aVersion.MajorVersion := dwFileVersionMS shr 16;
      aVersion.MinorVersion := dwFileVersionMS and $FFFF;
      aVersion.EditionVersion := dwFileVersionLS shr 16;
      aVersion.CompilationVersion := dwFileVersionLS and $FFFF;
    end;
    Result := True;
  finally
    FreeMem(lpVerInfo, dwInfoSize);
  end;
end;

{ TFileVersionRecord }

function TFileVersionRecord.ToString(const aFull: Boolean): string;
begin
  Result := IntToStr(MajorVersion) + '.' + IntToStr(MinorVersion);
  if aFull or (EditionVersion > 0) then
    Result := Result + '.' + IntToStr(EditionVersion);
  if aFull or (CompilationVersion > 0) then
    Result := Result + '.' + IntToStr(CompilationVersion);
end;

end.
