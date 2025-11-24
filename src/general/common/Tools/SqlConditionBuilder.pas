unit SqlConditionBuilder;

interface

type
  TSqlConditionStart = (EmptyStart, WhereStart, OnStart, AndStart, OrStart);

  ISqlConditionNode = interface
    ['{C26CCBE6-CD10-4374-8F69-BD7BE7F04216}']
    function GetConditionString(const aStart: TSqlConditionStart = TSqlConditionStart.WhereStart): string;
  end;

  ISqlConditionNodeInternal = interface
    ['{2F0AE743-6EAE-41AD-A38B-110C0C12F2E3}']
    function IsValid: Boolean;
    function GetCondition: string;
    procedure SetValue(const aValue: string);
  end;

  ISqlConditionNodeValue = interface;
  ISqlConditionNodeComparer = interface;
  ISqlConditionNodeOperator = interface(ISqlConditionNode)
    ['{1F4685C3-C008-4DB5-A841-AC4FF1C185EB}']
    function AddAnd: ISqlConditionNodeOperator;
    function AddOr: ISqlConditionNodeOperator;
    function AddNot: ISqlConditionNodeOperator;
    function AddRawSql(const aRawSql: string): ISqlConditionNodeOperator;
    function AddIsNull: ISqlConditionNodeValue; overload;
    function AddIsNull(const aValue: string): ISqlConditionNodeOperator; overload;
    function AddIsNotNull: ISqlConditionNodeValue; overload;
    function AddIsNotNull(const aValue: string): ISqlConditionNodeOperator; overload;
    function AddEquals: ISqlConditionNodeComparer;
    function AddNotEquals: ISqlConditionNodeComparer;
    function AddGreaterThan: ISqlConditionNodeComparer;
    function AddGreaterOrEqualThan: ISqlConditionNodeComparer;
    function AddLessThan: ISqlConditionNodeComparer;
    function AddLessOrEqualThan: ISqlConditionNodeComparer;
    function Add(const aNode: ISqlConditionNode): ISqlConditionNodeOperator;
    function GetParent: ISqlConditionNodeOperator;
    property Parent: ISqlConditionNodeOperator read GetParent;
  end;

  ISqlConditionNodeComparer = interface(ISqlConditionNode)
    ['{985BDA99-CC5E-4DBC-A470-92B50395FF66}']
    function Left(const aValue: string): ISqlConditionNodeComparer;
    function Right(const aValue: string): ISqlConditionNodeComparer;
    function GetParent: ISqlConditionNodeOperator;
    property Parent: ISqlConditionNodeOperator read GetParent;
  end;

  ISqlConditionNodeValue = interface(ISqlConditionNode)
    ['{6F263E71-7F18-4F00-8A47-74002914FBA9}']
    function GetValue: string;
    procedure SetValue(const aValue: string);
    function GetParent: ISqlConditionNodeComparer;
    function GetOperatorParent: ISqlConditionNodeOperator;
    property Value: string read GetValue write SetValue;
    property Parent: ISqlConditionNodeComparer read GetParent;
    property OperatorParent: ISqlConditionNodeOperator read GetOperatorParent;
  end;

  TSqlConditionBuilder = class
    class function CreateAnd: ISqlConditionNodeOperator;
    class function CreateOr: ISqlConditionNodeOperator;
    class function CreateNot: ISqlConditionNodeOperator;
    class function AddConditionStart(const aCondition: string; const aStart: TSqlConditionStart): string;
  end;

implementation

uses System.SysUtils, System.Generics.Collections, InterfacedBase, Joiner;

type
  TSqlConditionNodeBase = class abstract(TInterfacedBase, ISqlConditionNode, ISqlConditionNodeInternal)
  strict private
    function GetConditionString(const aStart: TSqlConditionStart): string;
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
    function AddRawSql(const aRawSql: string): ISqlConditionNodeOperator;
    function AddIsNull: ISqlConditionNodeValue; overload;
    function AddIsNull(const aValue: string): ISqlConditionNodeOperator; overload;
    function AddIsNotNull: ISqlConditionNodeValue; overload;
    function AddIsNotNull(const aValue: string): ISqlConditionNodeOperator; overload;
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
    function Add(const aNode: ISqlConditionNode): ISqlConditionNodeOperator; virtual;
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
    function Add(const aNode: ISqlConditionNode): ISqlConditionNodeOperator; override;
    function GetOperatorString: string; override;
  end;

  TSqlConditionNodeComparer = class abstract(TSqlConditionNodeBase, ISqlConditionNodeComparer)
  strict private
    fParent: ISqlConditionNodeOperator;
    fLeft: ISqlConditionNodeInternal;
    fRight: ISqlConditionNodeInternal;
    function GetParent: ISqlConditionNodeOperator;
    function Left(const aValue: string): ISqlConditionNodeComparer;
    function Right(const aValue: string): ISqlConditionNodeComparer;
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
    fParent: ISqlConditionNodeComparer;
    function GetOperatorParent: ISqlConditionNodeOperator;
    function GetParent: ISqlConditionNodeComparer;
  strict protected
    function IsValid: Boolean; override;
    function GetCondition: string; override;
    function GetValue: string;
    procedure SetValue(const aValue: string); override;
  public
    constructor Create(const aOperatorParent: ISqlConditionNodeOperator;
      const aParent: ISqlConditionNodeComparer; const aEmptyStringIsValid: Boolean);
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

function TSqlConditionNodeBase.GetConditionString(const aStart: TSqlConditionStart): string;
begin
  Result := TSqlConditionBuilder.AddConditionStart(GetCondition, aStart);
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
  Add(Result);
end;

function TSqlConditionNodeOperator.AddNot: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeNot.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddOr: ISqlConditionNodeOperator;
begin
  Result := TSqlConditionNodeOr.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddRawSql(const aRawSql: string): ISqlConditionNodeOperator;
begin
  Result := Self;
  var lNode: ISqlConditionNodeValue := TSqlConditionNodeValue.Create(Self, nil, False);
  lNode.Value := aRawSql;
  Add(lNode);
end;

function TSqlConditionNodeOperator.AddIsNull: ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValueIsNull.Create(Self, nil, False);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddIsNull(const aValue: string): ISqlConditionNodeOperator;
begin
  Result := Self;
  var lNode: ISqlConditionNodeValue := TSqlConditionNodeValueIsNull.Create(Self, nil, False);
  lNode.Value := aValue;
  Add(lNode);
end;

function TSqlConditionNodeOperator.AddIsNotNull: ISqlConditionNodeValue;
begin
  Result := TSqlConditionNodeValueIsNotNull.Create(Self, nil, False);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddIsNotNull(const aValue: string): ISqlConditionNodeOperator;
begin
  Result := Self;
  var lNode: ISqlConditionNodeValue := TSqlConditionNodeValueIsNotNull.Create(Self, nil, False);
  lNode.Value := aValue;
  Add(lNode);
end;

function TSqlConditionNodeOperator.AddEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeEquals.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddNotEquals: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeNotEquals.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddGreaterOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterOrEqualThan.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddGreaterThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeGreaterThan.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddLessOrEqualThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessOrEqualThan.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.AddLessThan: ISqlConditionNodeComparer;
begin
  Result := TSqlConditionNodeLessThan.Create(Self);
  Add(Result);
end;

function TSqlConditionNodeOperator.Add(const aNode: ISqlConditionNode): ISqlConditionNodeOperator;
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

function TSqlConditionNodeNot.Add(const aNode: ISqlConditionNode): ISqlConditionNodeOperator;
begin
  ClearNodes;
  Result := inherited Add(aNode);
end;

function TSqlConditionNodeNot.GetOperatorString: string;
begin
  Result := 'not';
end;

{ TSqlConditionNodeValue }

constructor TSqlConditionNodeValue.Create(const aOperatorParent: ISqlConditionNodeOperator;
  const aParent: ISqlConditionNodeComparer; const aEmptyStringIsValid: Boolean);
begin
  inherited Create;
  fOperatorParent := aOperatorParent;
  fParent := aParent;
  fEmptyStringIsValid := aEmptyStringIsValid;
end;

function TSqlConditionNodeValue.GetOperatorParent: ISqlConditionNodeOperator;
begin
  Result := fOperatorParent;
end;

function TSqlConditionNodeValue.GetParent: ISqlConditionNodeComparer;
begin
  Result := fParent;
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

class function TSqlConditionBuilder.AddConditionStart(const aCondition: string;
  const aStart: TSqlConditionStart): string;
begin
  Result := '';
  if Length(aCondition) =  0 then
    Exit;

  case aStart of
    TSqlConditionStart.EmptyStart: Result := aCondition;
    TSqlConditionStart.WhereStart: Result := 'where ' + aCondition;
    TSqlConditionStart.OnStart: Result := 'on ' + aCondition;
    TSqlConditionStart.AndStart: Result := 'and (' + aCondition + ')' ;
    TSqlConditionStart.OrStart: Result := 'or (' + aCondition + ')';
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

function TSqlConditionNodeComparer.Left(const aValue: string): ISqlConditionNodeComparer;
begin
  Result := Self;
  fLeft := TSqlConditionNodeValue.Create(nil, Self, True);
  fLeft.SetValue(aValue);
end;

function TSqlConditionNodeComparer.Right(const aValue: string): ISqlConditionNodeComparer;
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
