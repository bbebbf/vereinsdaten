unit Joiner;

interface

uses System.Classes, System.Generics.Collections;

type
  TObjectJoinerOnElementToStr<T> = procedure(Sender: TObject; const aElement: T;
    var aElementStr: string) of object;

  TJoiner<T> = class
  strict private
    fStrings: TStrings;
    fLineLeading: string;
    fLineTrailing: string;
    fLineElementLimit: Integer;
    fElementSeparator: string;
    fElementLeading: string;
    fElementTrailing: string;
    fOnElementToStr: TObjectJoinerOnElementToStr<T>;
    fAddTrailingPending: Boolean;

    fCurrentElementCount: Integer;
    fCurrentElementPerStringCount: Integer;
    function GetStrings: TArray<string>;
  strict protected
    function ElementToStr(const aElement: T): string; virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const aElement: T); overload;
    function Add(const aElements: TEnumerable<T>): Integer; overload;
    function Add(const aElements: TArray<T>): Integer; overload;
    property Strings: TArray<string> read GetStrings;
    property LineLeading: string read fLineLeading write fLineLeading;
    property LineTrailing: string read fLineTrailing write fLineTrailing;
    property LineElementLimit: Integer read fLineElementLimit write fLineElementLimit;
    property ElementSeparator: string read fElementSeparator write fElementSeparator;
    property ElementLeading: string read fElementLeading write fElementLeading;
    property ElementTrailing: string read fElementTrailing write fElementTrailing;
    property OnElementToStr: TObjectJoinerOnElementToStr<T> read fOnElementToStr write fOnElementToStr;
  end;

implementation

uses System.SysUtils, System.TypInfo, System.Rtti, System.Variants;

{ TJoiner<T> }

constructor TJoiner<T>.Create;
begin
  inherited Create;
  fStrings := TStringList.Create;
end;

destructor TJoiner<T>.Destroy;
begin
  fStrings.Free;
  inherited;
end;

procedure TJoiner<T>.Clear;
begin
  fCurrentElementCount := 0;
  fCurrentElementPerStringCount := 0;
  fStrings.Clear;
end;

procedure TJoiner<T>.Add(const aElement: T);
begin
  Inc(fCurrentElementPerStringCount);
  Inc(fCurrentElementCount);

  var lLastIndex := fStrings.Count - 1;
  if (lLastIndex < 0) or ((fLineElementLimit > 0) and (fCurrentElementPerStringCount > fLineElementLimit)) then
  begin
    if lLastIndex >= 0 then
    begin
      fStrings[lLastIndex] := fStrings[lLastIndex] + fLineTrailing;
    end;
    fStrings.Add(fLineLeading);

    lLastIndex := fStrings.Count - 1;
    fCurrentElementPerStringCount := 1;
  end;

  var lElementStr := ElementToStr(aElement);
  var lNewPart := '';
  if fCurrentElementPerStringCount > 1 then
    lNewPart := fElementSeparator;
  lNewPart := lNewPart + lElementStr;

  fStrings[lLastIndex] := fStrings[lLastIndex] + lNewPart;
  fAddTrailingPending := True;
end;

function TJoiner<T>.Add(const aElements: TEnumerable<T>): Integer;
begin
  Result := 0;
  for var i in aElements do
  begin
    Inc(Result);
    Add(i);
  end;
end;

function TJoiner<T>.Add(const aElements: TArray<T>): Integer;
begin
  Result := 0;
  for var i in aElements do
  begin
    Inc(Result);
    Add(i);
  end;
end;

function TJoiner<T>.ElementToStr(const aElement: T): string;
begin
  var lElemStr := '';
  if Assigned(fOnElementToStr) then
  begin
    fOnElementToStr(Self, aElement, lElemStr);
  end
  else
  begin
    lElemStr := VarToStr(TValue.From<T>(aElement).AsVariant);
  end;
  Result := fElementLeading + lElemStr + fElementTrailing;
end;

function TJoiner<T>.GetStrings: TArray<string>;
begin
  if fAddTrailingPending then
  begin
    var lLastIndex := fStrings.Count - 1;
    fStrings[lLastIndex] := fStrings[lLastIndex] + fLineTrailing;
    fAddTrailingPending := False;
  end;

  SetLength(Result, fStrings.Count);
  for var i := 0 to fStrings.Count - 1 do
    Result[i] := fStrings[i];
end;

end.
