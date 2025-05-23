unit MemberOfUI;

interface

uses ListEnumerator, ListCrudCommands, DtoMemberAggregated, MemberOfBusinessIntf, Vdm.Versioning.Types;

type
  IMemberOfUI = interface(IListEnumerator<TListEntry<TDtoMemberAggregated>>)
    ['{2CF51ACA-3DB6-4DE2-B4C3-EF18FEAE9A9D}']
    procedure SetCommands(const aCommands: IMemberOfBusinessIntf);
  end;

implementation

end.
