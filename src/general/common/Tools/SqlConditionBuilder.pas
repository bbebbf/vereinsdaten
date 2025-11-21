unit SqlConditionBuilder;

interface

type
  TSqlConditionKind = (EmptyKind, WhereKind, OnKind, AndKind, OrKind);

  ISqlConditionNodeBase = interface
    ['{85C653A1-3BD5-40F0-B0D8-6E483A105300}']
    function GetConditionString(const aKind: TSqlConditionKind = TSqlConditionKind.WhereKind): string;
  end;

  ISqlConditionNodeValue = interface;
  ISqlConditionNodeComparer = interface;
  ISqlConditionNodeOperator = interface(ISqlConditionNodeBase)
    ['{1F4685C3-C008-4DB5-A841-AC4FF1C185EB}']
    function AddAnd: ISqlConditionNodeOperator;
    function AddOr: ISqlConditionNodeOperator;
    function AddNot: ISqlConditionNodeOperator;
    function AddValue(const aValue: string = ''): ISqlConditionNodeValue;
    function AddEquals: ISqlConditionNodeComparer;
    function AddNotEquals: ISqlConditionNodeComparer;
    function AddGreaterThan: ISqlConditionNodeComparer;
    function AddGreaterOrEqualThan: ISqlConditionNodeComparer;
    function AddLessThan: ISqlConditionNodeComparer;
    function AddLessOrEqualThan: ISqlConditionNodeComparer;
    procedure AddNode(const aNode: ISqlConditionNodeBase);
  end;

  ISqlConditionNodeComparer = interface(ISqlConditionNodeBase)
    ['{985BDA99-CC5E-4DBC-A470-92B50395FF66}']
    function SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
    function SetRightValue(const aValue: string): ISqlConditionNodeComparer;
  end;

  ISqlConditionNodeValue = interface(ISqlConditionNodeBase)
    ['{6F263E71-7F18-4F00-8A47-74002914FBA9}']
    function GetValue: string;
    procedure SetValue(const aValue: string);
    property Value: string read GetValue write SetValue;
  end;

  TSqlConditionBuilder = class
    class function CreateAnd: ISqlConditionNodeOperator;
    class function CreateOr: ISqlConditionNodeOperator;
    class function CreateNot: ISqlConditionNodeOperator;
    class function KindToKeyword(const aKind: TSqlConditionKind): string;
  end;

implementation

uses System.Generics.Collections, InterfacedBase;

type
  TSqlConditionNodeOperator = class abstract(TInterfacedBase, ISqlConditionNodeOperator)
  strict private
    fNodes: TList<ISqlConditionNodeBase>;
    function GetConditionString(const aKind: TSqlConditionKind): string;
    function AddAnd: ISqlConditionNodeOperator;
    function AddOr: ISqlConditionNodeOperator;
    function AddNot: ISqlConditionNodeOperator;
    function AddValue(const aValue: string): ISqlConditionNodeValue;
    function AddEquals: ISqlConditionNodeComparer;
    function AddNotEquals: ISqlConditionNodeComparer;
    function AddGreaterThan: ISqlConditionNodeComparer;
    function AddGreaterOrEqualThan: ISqlConditionNodeComparer;
    function AddLessThan: ISqlConditionNodeComparer;
    function AddLessOrEqualThan: ISqlConditionNodeComparer;
  strict protected
    procedure AddNode(const aNode: ISqlConditionNodeBase); virtual;
    procedure ClearNodes;
    function GetNodeCount: Integer;
    function GetConditionStringInternal: string;
    function GetOperatorString: string; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TSqlConditionNodeAnd = class(TSqlConditionNodeOperator)
  strict protected
    function GetOperatorString: string; override;
  end;

  TSqlConditionNodeOr = class(TSqlConditionNodeOperator)
  strict protected
    function GetOperatorString: string; override;
  end;

  TSqlConditionNodeNot = class(TSqlConditionNodeOperator)
  strict protected
    procedure AddNode(const aNode: ISqlConditionNodeBase); override;
    function GetOperatorString: string; override;
  end;

  TSqlConditionNodeComparer = class abstract(TInterfacedBase, ISqlConditionNodeComparer)
  strict private
    fLeft: ISqlConditionNodeValue;
    fRight: ISqlConditionNodeValue;
    function GetConditionString(const aKind: TSqlConditionKind): string;
    function SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
    function SetRightValue(const aValue: string): ISqlConditionNodeComparer;
  strict protected
    function GetComparerString: string; virtual; abstract;
  end;

  TSqlConditionNodeEquals = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeNotEquals = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeGreaterThan = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeGreaterOrEqualThan = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeLessThan = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeLessOrEqualThan = class(TSqlConditionNodeComparer)
  strict protected
    function GetComparerString: string; override;
  end;

  TSqlConditionNodeValue = class(TInterfacedBase, ISqlConditionNodeValue)
  strict private
    fValue: string;
    function GetConditionString(const aKind: TSqlConditionKind): string;
    function GetValue: string;
    procedure SetValue(const aValue: string);
  end;

{ TSqlConditionNodeOperator }

constructor TSqlConditionNodeOperator.Create;
begin
  inherited Create;
  fNodes := TList<ISqlConditionNodeBase>.Create;
end;

destructor TSqlConditionNodeOperator.Destroy;
begin
  fNodes.Free;
  inherited;
end;

function TSqlConditionNodeOperator.GetConditionString(const aKind: TSqlConditionKind): string;
begin
  if GetNodeCount = 0 then
    Exit('');

  Result := TSqlConditionBuilder.KindToKeyword(aKind) + ' (' + GetConditionStringInternal + ')';
end;

function TSqlConditionNodeOperator.GetConditionStringInternal: string;
begin
  Result := fNodes[0].GetConditionString;
  for var i := 1 to fNodes.Count - 1 do
    Result := Result + ' ' + GetOperatorString + ' ' + fNodes[i].GetConditionString;
end;

function TSqlConditionNodeOperator.GetNodeCount: Integer;
begin
  Result := fNodes.Count;
end;

procedure TSqlConditionNodeOperator.ClearNodes;
begin
  fNodes.Clear;
end;

function TSqlConditionNodeOperator.AddAnd: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeAnd.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddNot: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeNot.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddOr: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeOr.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddValue(const aValue: string): ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValue.Create;
  Result.Value := aValue;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeEquals.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddNotEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeNotEquals.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddGreaterOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterOrEqualThan.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddGreaterThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterThan.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddLessOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessOrEqualThan.Create;
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddLessThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessThan.Create;
  AddNode(Result);
end;

procedure TSqlConditionNodeOperator.AddNode(const aNode: ISqlConditionNodeBase);
begin
  fNodes.Add(aNode);
end;

{ TSqlConditionNodeAnd }

function TSqlConditionNodeAnd.GetOperatorString: string;
begin
  Result := 'and';
end;

{ TSqlConditionNodeOr }

function TSqlConditionNodeOr.GetOperatorString: string;
begin
  Result := 'or';
end;

{ TSqlConditionNodeNot }

procedure TSqlConditionNodeNot.AddNode(const aNode: ISqlConditionNodeBase);
begin
  ClearNodes;
  inherited;
end;

function TSqlConditionNodeNot.GetOperatorString: string;
begin
  Result := 'not';
end;

{ TSqlConditionNodeValue }

function TSqlConditionNodeValue.GetConditionString(const aKind: TSqlConditionKind): string;
begin
  Result := TSqlConditionBuilder.KindToKeyword(aKind) + ' (' + fValue + ')';
end;

function TSqlConditionNodeValue.GetValue: string;
begin
  Result := fValue;
end;

procedure TSqlConditionNodeValue.SetValue(const aValue: string);
begin
  fValue := aValue;
end;

{ TSqlConditionBuilder }

class function TSqlConditionBuilder.CreateAnd: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeAnd.Create;
end;

class function TSqlConditionBuilder.CreateNot: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeNot.Create;
end;

class function TSqlConditionBuilder.CreateOr: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeOr.Create;
end;

class function TSqlConditionBuilder.KindToKeyword(const aKind: TSqlConditionKind): string;
begin
  case aKind of
    TSqlConditionKind.EmptyKind: Result := '';
    TSqlConditionKind.WhereKind: Result := 'where';
    TSqlConditionKind.OnKind: Result := 'on';
    TSqlConditionKind.AndKind: Result := 'and';
    TSqlConditionKind.OrKind: Result := 'or';
    else Result := '';
  end;
end;

{ TSqlConditionNodeComparer }

function TSqlConditionNodeComparer.GetConditionString(const aKind: TSqlConditionKind): string;
begin
  if not Assigned(fLeft) or not Assigned(fRight) then
    Exit('');

  Result := TSqlConditionBuilder.KindToKeyword(aKind) +
    ' (' + fLeft.Value + ' ' + GetComparerString + ' ' + fRight.Value + ')';
end;

function TSqlConditionNodeComparer.SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
begin
  Result := Self;
  fLeft := TSqlConditionNodeValue.Create;
  fLeft.Value := aValue;
end;

function TSqlConditionNodeComparer.SetRightValue(const aValue: string): ISqlConditionNodeComparer;
begin
  Result := Self;
  fRight := TSqlConditionNodeValue.Create;
  fRight.Value := aValue;
end;

{ TSqlConditionNodeEquals }

function TSqlConditionNodeEquals.GetComparerString: string;
begin
  Result := '=';
end;

{ TSqlConditionNodeNotEquals }

function TSqlConditionNodeNotEquals.GetComparerString: string;
begin
  Result := '<>';
end;

{ TSqlConditionNodeGreaterThan }

function TSqlConditionNodeGreaterThan.GetComparerString: string;
begin
  Result := '>';
end;

{ TSqlConditionNodeGreaterOrEqualThan }

function TSqlConditionNodeGreaterOrEqualThan.GetComparerString: string;
begin
  Result := '>=';
end;

{ TSqlConditionNodeLessThan }

function TSqlConditionNodeLessThan.GetComparerString: string;
begin
  Result := '<';
end;

{ TSqlConditionNodeLessOrEqualThan }

function TSqlConditionNodeLessOrEqualThan.GetComparerString: string;
begin
  Result := '<=';
end;

end.
