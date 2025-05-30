unit Vdm.Versioning.Types;

{$I \inc\CompilerDirectives.inc }

interface

uses SqlConnection;

type
  TEntryVersionInfoEntity = (Undefined, PersonBaseData, PersonMemberOfs, Units, Addresses);

  TEntryVersionInfo = record
    Id: UInt32;
    VersionNumber: UInt32;
    LastUpdated: TDateTime;
  end;

  ISelectVersionInfo = interface
    ['{4D04C0C5-39E7-44EB-B311-3231D8DE1F21}']
    function GetEntryVersionInfoFromResult(const aSqlResult: ISqlResult; out aEntry: TEntryVersionInfo): Boolean;
  end;

  IVersionInfoSetter<T> = interface
    ['{2C4F9B2E-56EA-46A0-B573-139D44F6B657}']
    procedure SetVersionInfo(const aVersionInfos: TArray<TEntryVersionInfo>; var aEntry: T);
  end;

  IVersionInfoConfig<TRecord, TRecordIdentity> = interface
    ['{585E7E27-83C6-41E1-B03C-3EBD49EEAD3D}']
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TRecord): TRecordIdentity;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: TRecordIdentity; const aParameter: ISqlParameter);
  end;

  TVersionInfoEntryState = (Undefined, Updated, ServerConflict);

  TVersionInfoEntry = class
  strict private
    fState: TVersionInfoEntryState;
    fLocalVersionInfo: TEntryVersionInfo;
    fServerVersionInfo: TEntryVersionInfo;
    function EntryVersionInfoToString(const aValue: TEntryVersionInfo): string;
  public
    function ToString: string; override;
    procedure Assign(const aVersionInfoEntry: TVersionInfoEntry);
    procedure Reset;
    procedure RegisterVersionConflict(const aServerVersionInfo: TEntryVersionInfo);
    procedure UpdateVersionInfo(const aVersionInfo: TEntryVersionInfo);
    property State: TVersionInfoEntryState read fState;
    property LocalVersionInfo: TEntryVersionInfo read fLocalVersionInfo;
    property ServerVersionInfo: TEntryVersionInfo read fServerVersionInfo;
  end;
  TVersioningResponseVersioningState = (NoConflict, ConflictDetected, VersionUpdated, InvalidVersionInfo);

  TVersioningLoadResponse = record
    Succeeded: Boolean;
    EntryVersionInfo: TEntryVersionInfo;
  end;

  TVersioningSaveKind = (Created, Updated);
  TVersioningSaveResponse = record
    Kind: TVersioningSaveKind;
    VersioningState: TVersioningResponseVersioningState;
  end;

  TVersioningDeleteResponse = record
    Succeeded: Boolean;
    VersioningState: TVersioningResponseVersioningState;
    ConflictedEntryVersionInfo: TEntryVersionInfo;
  end;

implementation

uses System.SysUtils, Vdm.Globals;

{ TVersionInfoEntry }

procedure TVersionInfoEntry.Assign(const aVersionInfoEntry: TVersionInfoEntry);
begin
  fState := aVersionInfoEntry.State;
  fLocalVersionInfo := aVersionInfoEntry.LocalVersionInfo;
  fServerVersionInfo := aVersionInfoEntry.ServerVersionInfo;
end;

procedure TVersionInfoEntry.RegisterVersionConflict(const aServerVersionInfo: TEntryVersionInfo);
begin
  fServerVersionInfo := aServerVersionInfo;
  fState := TVersionInfoEntryState.ServerConflict;
end;

procedure TVersionInfoEntry.Reset;
begin
  fLocalVersionInfo := default(TEntryVersionInfo);
  fServerVersionInfo := default(TEntryVersionInfo);
  fState := TVersionInfoEntryState.Undefined;
end;

function TVersionInfoEntry.ToString: string;
begin
  case fState of
    TVersionInfoEntryState.Undefined:
    begin
      Result := 'nicht definiert';
    end;
    TVersionInfoEntryState.Updated:
    begin
      Result := EntryVersionInfoToString(fLocalVersionInfo);
    end;
    TVersionInfoEntryState.ServerConflict:
    begin
      Result := 'Lokal: ' + EntryVersionInfoToString(fLocalVersionInfo) +
        ' <> Server: ' + EntryVersionInfoToString(fServerVersionInfo);
    end;
    else
    begin
      Result := 'Not implemented.';
    end;
  end;
end;

function TVersionInfoEntry.EntryVersionInfoToString(const aValue: TEntryVersionInfo): string;
begin
  if aValue.Id > 0 then
    Result := UIntToStr(aValue.VersionNumber) + ' (' + TVdmGlobals.GetTimeStampAsString(aValue.LastUpdated)  + ')'
  else
    Result := 'unbekannt';
end;

procedure TVersionInfoEntry.UpdateVersionInfo(const aVersionInfo: TEntryVersionInfo);
begin
  fLocalVersionInfo := aVersionInfo;
  fServerVersionInfo := aVersionInfo;
  fState := TVersionInfoEntryState.Updated;
end;

end.
