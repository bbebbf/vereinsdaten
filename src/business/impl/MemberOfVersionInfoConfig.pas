unit MemberOfVersionInfoConfig;

interface

uses InterfacedBase, Vdm.Versioning.Types, SqlConnection;

type
  TMemberOfVersionInfoConfig = class(TInterfacedBase, IVersionInfoConfig<UInt32, UInt32>)
  strict private
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: UInt32): UInt32;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: UInt32; const aParameter: ISqlParameter);
  end;

implementation

{ TMemberOfVersionInfoConfig }

function TMemberOfVersionInfoConfig.GetRecordIdentity(const aRecord: UInt32): UInt32;
begin
  Result := aRecord;
end;

function TMemberOfVersionInfoConfig.GetVersioningEntityId: TEntryVersionInfoEntity;
begin
  Result := TEntryVersionInfoEntity.PersonMemberOfs;
end;

function TMemberOfVersionInfoConfig.GetVersioningIdentityColumnName: string;
begin
  Result := 'person_id';
end;

procedure TMemberOfVersionInfoConfig.SetVersionInfoParameter(const aRecordIdentity: UInt32;
  const aParameter: ISqlParameter);
begin
  aParameter.Value := aRecordIdentity;
end;

end.
