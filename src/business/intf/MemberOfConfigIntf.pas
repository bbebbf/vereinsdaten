unit MemberOfConfigIntf;

interface

uses CrudConfig, DtoMember, KeyIndexStrings;

type
  IMemberOfConfigIntf = interface(ICrudConfig<TDtoMember, UInt32>)
    ['{4FE2EA3D-8575-4F35-A520-2803E54E1B88}']
    function GetDetailItemTitle: string;
    function GetDetailItemMapper: TActiveKeyIndexStringsLoader;
    function GetShowVersionInfoInMemberListview: Boolean;
    procedure SetMasterItemIdToMember(const aMasterItemId: UInt32; var aMember: TDtoMember);
    function GetDetailItemIdFromMember(const aMember: TDtoMember): UInt32;
    procedure SetDetailItemIdToMember(const aDetailItemId: UInt32; var aMember: TDtoMember);
    procedure GotoDetailItem(const aMember: TDtoMember);
  end;

implementation

end.
