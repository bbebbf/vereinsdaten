unit CrudConfigRole;

interface

uses System.SysUtils, SelectList, SqlConnection, DtoRole;

type
  TCrudConfigRole = class(TInterfacedObject, ISelectList<TDtoRole>)
  strict private
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoRole);
    function GetSelectListSQL: string;
  end;

implementation

{ TCrudConfigRole }

procedure TCrudConfigRole.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoRole);
begin
  aData.Id := aSqlResult.FieldByName('role_id').AsLargeInt;
  aData.Name := aSqlResult.FieldByName('role_name').AsString;
end;

function TCrudConfigRole.GetSelectListSQL: string;
begin
  Result := 'select * from role order by role_sorting, role_name';
end;

end.
