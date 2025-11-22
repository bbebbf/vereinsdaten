unit SqlConditionBuilder;

interface

type
  TSqlConditionKind = (EmptyKind, WhereKind, OnKind, AndKind, OrKind);

  ISqlConditionNodeBase = interface
    ['{C26CCBE6-CD10-4374-8F69-BD7BE7F04216}']
    function GetConditionString(const aKind: TSqlConditionKind = TSqlConditionKind.WhereKind): string;
  end;

  ISqlConditionNodeInternal = interface
    ['{2F0AE743-6EAE-41AD-A38B-110C0C12F2E3}']
    function IsValid: Boolean;
    function GetCondition: string;
    procedure SetValue(const aValue: string);
  end;

  ISqlConditionNodeValue = interface;
  ISqlConditionNodeComparer = interface;
  ISqlConditionNodeOperator = interface(ISqlConditionNodeBase)
    ['{1F4685C3-C008-4DB5-A841-AC4FF1C185EB}']
    function AddAnd: ISqlConditionNodeOperator;
    function AddOr: ISqlConditionNodeOperator;
    function AddNot: ISqlConditionNodeOperator;
    function Add(const aEmptyStringIsValid: Boolean = True): ISqlConditionNodeValue;
    function AddIsNull: ISqlConditionNodeValue;
    function AddIsNotNull: ISqlConditionNodeValue;
    function AddEquals: ISqlConditionNodeComparer;
    function AddNotEquals: ISqlConditionNodeComparer;
    function AddGreaterThan: ISqlConditionNodeComparer;
    function AddGreaterOrEqualThan: ISqlConditionNodeComparer;
    function AddLessThan: ISqlConditionNodeComparer;
    function AddLessOrEqualThan: ISqlConditionNodeComparer;
    function AddNode(const aNode: ISqlConditionNodeBase): ISqlConditionNodeOperator;
    function GetParent: ISqlConditionNodeOperator;
    property Parent: ISqlConditionNodeOperator read GetParent;
  end;

  ISqlConditionNodeComparer = interface(ISqlConditionNodeBase)
    ['{985BDA99-CC5E-4DBC-A470-92B50395FF66}']
    function SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
    function SetRightValue(const aValue: string): ISqlConditionNodeComparer;
    function GetParent: ISqlConditionNodeOperator;
    property Parent: ISqlConditionNodeOperator read GetParent;
  end;

  ISqlConditionNodeValue = interface(ISqlConditionNodeBase)
    ['{6F263E71-7F18-4F00-8A47-74002914FBA9}']
    function GetValue: string;
    procedure SetValue(const aValue: string);
    function GetOperatorParent: ISqlConditionNodeOperator;
    function GetComparerParent: ISqlConditionNodeComparer;
    property Value: string read GetValue write SetValue;
    property OperatorParent: ISqlConditionNodeOperator read GetOperatorParent;
    property ComparerParent: ISqlConditionNodeComparer read GetComparerParent;
  end;

  TSqlConditionBuilder = class
    class function CreateAnd: ISqlConditionNodeOperator;
    class function CreateOr: ISqlConditionNodeOperator;
    class function CreateNot: ISqlConditionNodeOperator;
    class function KindToKeyword(const aKind: TSqlConditionKind): string;
  end;

implementation

uses System.SysUtils, System.Generics.Collections, InterfacedBase, Joiner;

type
  TSqlConditionNodeBase = class abstract(TInterfacedBase, ISqlConditionNodeBase, ISqlConditionNodeInternal)
  strict private
    function GetConditionString(const aKind: TSqlConditionKind): string;
  strict protected
    function IsValid: Boolean; virtual; abstract;
    function GetCondition: string; virtual; abstract;
    procedure SetValue(const aValue: string); virtual;
  end;

  TSqlConditionNodeOperator = class abstract(TSqlConditionNodeBase, ISqlConditionNodeOperator)
  strict private
    fParent: ISqlConditionNodeOperator;
    fNodes: TList<ISqlConditionNodeInternal>;
    function AddAnd: ISqlConditionNodeOperator;
    function AddOr: ISqlConditionNodeOperator;
    function AddNot: ISqlConditionNodeOperator;
    function Add(const aEmptyStringIsValid: Boolean): ISqlConditionNodeValue;
    function AddIsNull: ISqlConditionNodeValue;
    function AddIsNotNull: ISqlConditionNodeValue;
    function AddEquals: ISqlConditionNodeComparer;
    function AddNotEquals: ISqlConditionNodeComparer;
    function AddGreaterThan: ISqlConditionNodeComparer;
    function AddGreaterOrEqualThan: ISqlConditionNodeComparer;
    function AddLessThan: ISqlConditionNodeComparer;
    function AddLessOrEqualThan: ISqlConditionNodeComparer;
    function GetParent: ISqlConditionNodeOperator;
  strict protected
    function IsValid: Boolean; override;
    function GetCondition: string; override;
    function AddNode(const aNode: ISqlConditionNodeBase): ISqlConditionNodeOperator; virtual;
    procedure ClearNodes;
    function GetOperatorString: string; virtual; abstract;
  public
    constructor Create(const aParent: ISqlConditionNodeOperator);
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
    function AddNode(const aNode: ISqlConditionNodeBase): ISqlConditionNodeOperator; override;
    function GetOperatorString: string; override;
  end;

  TSqlConditionNodeComparer = class abstract(TSqlConditionNodeBase, ISqlConditionNodeComparer)
  strict private
    fParent: ISqlConditionNodeOperator;
    fLeft: ISqlConditionNodeInternal;
    fRight: ISqlConditionNodeInternal;
    function GetParent: ISqlConditionNodeOperator;
    function SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
    function SetRightValue(const aValue: string): ISqlConditionNodeComparer;
  strict protected
    function IsValid: Boolean; override;
    function GetCondition: string; override;
    function GetComparerString: string; virtual; abstract;
  public
    constructor Create(const aParent: ISqlConditionNodeOperator);
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

  TSqlConditionNodeValue = class(TSqlConditionNodeBase, ISqlConditionNodeValue)
  strict private
    fValue: string;
    fEmptyStringIsValid: Boolean;
    fValueIsValid: Boolean;
    fOperatorParent: ISqlConditionNodeOperator;
    fComparerParent: ISqlConditionNodeComparer;
    function GetOperatorParent: ISqlConditionNodeOperator;
    function GetComparerParent: ISqlConditionNodeComparer;
  strict protected
    function IsValid: Boolean; override;
    function GetCondition: string; override;
    function GetValue: string;
    procedure SetValue(const aValue: string); override;
  public
    constructor Create(const aOperatorParent: ISqlConditionNodeOperator;
      const aComparerParent: ISqlConditionNodeComparer; const aEmptyStringIsValid: Boolean);
  end;

  TSqlConditionNodeValueIsNull = class(TSqlConditionNodeValue)
  strict protected
    function GetCondition: string; override;
  end;

  TSqlConditionNodeValueIsNotNull = class(TSqlConditionNodeValue)
  strict protected
    function GetCondition: string; override;
  end;

{ TSqlConditionNodeBase }

function TSqlConditionNodeBase.GetConditionString(const aKind: TSqlConditionKind): string;
begin
  Result := GetCondition;
  if Length(Result) > 0 then
    Result := TSqlConditionBuilder.KindToKeyword(aKind) + ' ' + Result;
end;

procedure TSqlConditionNodeBase.SetValue(const aValue: string);
begin

end;

{ TSqlConditionNodeOperator }

constructor TSqlConditionNodeOperator.Create(const aParent: ISqlConditionNodeOperator);
begin
  inherited Create;
  fParent := aParent;
  fNodes := TList<ISqlConditionNodeInternal>.Create;
end;

destructor TSqlConditionNodeOperator.Destroy;
begin
  fNodes.Free;
  inherited;
end;

function TSqlConditionNodeOperator.GetCondition: string;
begin
  Result := '';
  var lOpenPa := '';
  var lClosedPa := '';
  if fNodes.Count > 1 then
  begin
    lOpenPa := '(';
    lClosedPa := ')';
  end;

  var lJoiner := TJoiner<string>.Create;
  try
    lJoiner.ElementSeparator := ' ' + GetOperatorString + ' ';
    lJoiner.ElementLeading := lOpenPa;
    lJoiner.ElementTrailing := lClosedPa;
    for var i in fNodes do
    begin
      if i.IsValid then
        lJoiner.Add(i.GetCondition);
    end;
    if Length(lJoiner.Strings) > 0 then
      Result := lJoiner.Strings[0];
  finally
    lJoiner.Free;
  end;
end;

function TSqlConditionNodeOperator.GetParent: ISqlConditionNodeOperator;
begin
  Result := fParent;
end;

function TSqlConditionNodeOperator.IsValid: Boolean;
begin
  Result := False;
  for var i in fNodes do
  begin
    if i.IsValid then
      Exit(True);
  end;
end;

procedure TSqlConditionNodeOperator.ClearNodes;
begin
  fNodes.Clear;
end;

function TSqlConditionNodeOperator.AddAnd: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeAnd.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddNot: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeNot.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddOr: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeOr.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.Add(const aEmptyStringIsValid: Boolean): ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValue.Create(Self, nil, aEmptyStringIsValid);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddIsNull: ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValueIsNull.Create(Self, nil, False);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddIsNotNull: ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValueIsNotNull.Create(Self, nil, False);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeEquals.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddNotEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeNotEquals.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddGreaterOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterOrEqualThan.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddGreaterThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterThan.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddLessOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessOrEqualThan.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddLessThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessThan.Create(Self);
  AddNode(Result);
end;

function TSqlConditionNodeOperator.AddNode(const aNode: ISqlConditionNodeBase): ISqlConditionNodeOperator;
begin
  Result := Self;
  var lInternalNode: ISqlConditionNodeInternal;
  if Supports(aNode, ISqlConditionNodeInternal, lInternalNode) then
    fNodes.Add(lInternalNode);
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

function TSqlConditionNodeNot.AddNode(const aNode: ISqlConditionNodeBase): ISqlConditionNodeOperator;
begin
  ClearNodes;
  Result := inherited AddNode(aNode);
end;

function TSqlConditionNodeNot.GetOperatorString: string;
begin
  Result := 'not';
end;

{ TSqlConditionNodeValue }

constructor TSqlConditionNodeValue.Create(const aOperatorParent: ISqlConditionNodeOperator;
  const aComparerParent: ISqlConditionNodeComparer; const aEmptyStringIsValid: Boolean);
begin
  inherited Create;
  fOperatorParent := aOperatorParent;
  fComparerParent := aComparerParent;
  fEmptyStringIsValid := aEmptyStringIsValid;
end;

function TSqlConditionNodeValue.GetOperatorParent: ISqlConditionNodeOperator;
begin
  Result := fOperatorParent;
end;

function TSqlConditionNodeValue.GetComparerParent: ISqlConditionNodeComparer;
begin
  Result := fComparerParent;
end;

function TSqlConditionNodeValue.GetCondition: string;
begin
  Result := fValue;
end;

function TSqlConditionNodeValue.GetValue: string;
begin
  Result := fValue;
end;

function TSqlConditionNodeValue.IsValid: Boolean;
begin
  Result := fValueIsValid;
end;

procedure TSqlConditionNodeValue.SetValue(const aValue: string);
begin
  fValue := aValue;
  fValueIsValid := fEmptyStringIsValid or (Length(fValue) > 0);
end;

{ TSqlConditionBuilder }

class function TSqlConditionBuilder.CreateAnd: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeAnd.Create(nil);
end;

class function TSqlConditionBuilder.CreateNot: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeNot.Create(nil);
end;

class function TSqlConditionBuilder.CreateOr: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeOr.Create(nil);
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

constructor TSqlConditionNodeComparer.Create(const aParent: ISqlConditionNodeOperator);
begin
  inherited Create;
  fParent := aParent;
end;

function TSqlConditionNodeComparer.GetCondition: string;
begin
  Result := fLeft.GetCondition + ' ' + GetComparerString + ' ' + fRight.GetCondition;
end;

function TSqlConditionNodeComparer.GetParent: ISqlConditionNodeOperator;
begin
  Result := fParent;
end;

function TSqlConditionNodeComparer.IsValid: Boolean;
begin
  Result := Assigned(fLeft) and Assigned(fRight);
end;

function TSqlConditionNodeComparer.SetLeftValue(const aValue: string): ISqlConditionNodeComparer;
begin
  Result := Self;
  fLeft := TSqlConditionNodeValue.Create(nil, Self, True);
  fLeft.SetValue(aValue);
end;

function TSqlConditionNodeComparer.SetRightValue(const aValue: string): ISqlConditionNodeComparer;
begin
  Result := Self;
  fRight := TSqlConditionNodeValue.Create(nil, Self, True);
  fRight.SetValue(aValue);
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

{ TSqlConditionNodeValueIsNull }

function TSqlConditionNodeValueIsNull.GetCondition: string;
begin
  Result := GetValue + ' is null';
end;

{ TSqlConditionNodeValueIsNotNull }

function TSqlConditionNodeValueIsNotNull.GetCondition: string;
begin
  Result := GetValue + ' is not null';
end;

end.
