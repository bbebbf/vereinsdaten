unit VersionInfoConfig;

interface

uses SqlConnection, Vdm.Versioning.Types;

type
  IVersionInfoConfig<TRecord, TRecordIdentity> = interface
    ['{585E7E27-83C6-41E1-B03C-3EBD49EEAD3D}']
    function GetVersioningEntityId: TEntryVersionInfoEntity;
    function GetRecordIdentity(const aRecord: TRecord): TRecordIdentity;
    function GetVersioningIdentityColumnName: string;
    procedure SetVersionInfoParameter(const aRecordIdentity: TRecordIdentity; const aParameter: ISqlParameter);
  end;

implementation

end.
