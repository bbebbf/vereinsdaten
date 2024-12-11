unit CrudConfigUnit;

interface

uses System.SysUtils, SelectList, SqlConnection, DtoUnit;

type
  TCrudConfigUnit = class(TInterfacedObject, ISelectList<TDtoUnit>)
  strict private
    procedure GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoUnit);
    function GetSelectListSQL: string;
  end;

implementation

{ TCrudConfigUnit }

procedure TCrudConfigUnit.GetRecordFromSqlResult(const aSqlResult: ISqlResult; var aData: TDtoUnit);
begin
  aData.Id := aSqlResult.FieldByName('unit_id').AsLargeInt;
  aData.Name := aSqlResult.FieldByName('unit_name').AsString;
end;

function TCrudConfigUnit.GetSelectListSQL: string;
begin
  Result := 'select * from unit order by unit_name';
end;

end.
