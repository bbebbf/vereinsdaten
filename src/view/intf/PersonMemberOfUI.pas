unit PersonMemberOfUI;

interface

uses ListEnumerator, DtoMemberAggregated, MemberOfBusinessIntf;

type
  IPersonMemberOfUI = interface(IListEnumerator<TDtoMemberAggregated>)
    ['{2CF51ACA-3DB6-4DE2-B4C3-EF18FEAE9A9D}']
    procedure Initialize(const aCommands: IMemberOfBusinessIntf);
  end;

implementation

end.
