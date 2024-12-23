unit MasterdataBusiness;

interface

uses System.SysUtils, CrudCommands, CrudUI, MasterdataBusinessIntf;

type
  TMasterdataBusiness<TEntry: class; TId: record> = class(TInterfacedObject, IMasterdataBusinessIntf<TEntry, TId>)
  strict private
    fUI: ICrudUI<TEntry, TId>;
    procedure Initialize;
    function LoadList: TCrudCommandResult;
    function LoadCurrentRecord(const aId: TId): TCrudCommandResult;
    function SaveCurrentRecord(const aId: TId): TCrudSaveRecordResult;
    function ReloadCurrentRecord(const aId: TId): TCrudCommandResult;
    function DeleteRecord(const aId: TId): TCrudCommandResult;
  public
    constructor Create(const aUI: ICrudUI<TEntry, TId>);
  end;

implementation

{ TMasterdataBusiness<TEntry, TId> }

constructor TMasterdataBusiness<TEntry, TId>.Create(const aUI: ICrudUI<TEntry, TId>);
begin
  inherited Create;
  fUI := aUI;
end;

procedure TMasterdataBusiness<TEntry, TId>.Initialize;
begin
  var lCrudCommands: ICrudCommands<TId>;
  if Supports(Self, ICrudCommands<TId>, lCrudCommands) then
    fUI.Initialize(lCrudCommands);
end;

function TMasterdataBusiness<TEntry, TId>.LoadList: TCrudCommandResult;
begin

end;

function TMasterdataBusiness<TEntry, TId>.LoadCurrentRecord(const aId: TId): TCrudCommandResult;
begin

end;

function TMasterdataBusiness<TEntry, TId>.SaveCurrentRecord(const aId: TId): TCrudSaveRecordResult;
begin

end;

function TMasterdataBusiness<TEntry, TId>.ReloadCurrentRecord(const aId: TId): TCrudCommandResult;
begin

end;

function TMasterdataBusiness<TEntry, TId>.DeleteRecord(const aId: TId): TCrudCommandResult;
begin

end;

end.
