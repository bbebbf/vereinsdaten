unit Windows.API.Tools;

interface

type
  TWindowsAPITools = class
  public
    class function OpenFolderAndSelectFile(const aFilePath: string): Boolean;
  end;

implementation

uses
  Windows, ShellAPI, ShlObj;

{$IFDEF UNICODE}
function ILCreateFromPath(const pszPath: PWideChar): PItemIDList stdcall; external 'shell32' name 'ILCreateFromPathW';
{$ELSE}
function ILCreateFromPath(pszPath: PChar): PItemIDList stdcall; external 'shell32' name 'ILCreateFromPathA';
{$ENDIF}
procedure ILFree(pidl: PItemIDList) stdcall; external shell32;
function SHOpenFolderAndSelectItems(pidlFolder: PItemIDList; cidl: Cardinal; apidl: pointer; dwFlags: DWORD): HRESULT; stdcall; external shell32;

{ TWindowsAPITools }

class function TWindowsAPITools.OpenFolderAndSelectFile(const aFilePath: string): Boolean;
begin
  Result := False;
  var IIDL := ILCreateFromPath(PWideChar(aFilePath));
  if IIDL <> nil then
  begin
    try
      Result := SHOpenFolderAndSelectItems(IIDL, 0, nil, 0) = S_OK;
    finally
      ILFree(IIDL);
    end;
  end;
end;

end.
