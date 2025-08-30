unit Helper.ConstraintControls;

interface

uses ConstraintControls.DateEdit, ConstraintControls.IntegerEdit, SimpleDate, Nullable;

type
  TDateEditValueHelper = class helper for TDateEditValue
  public
    procedure ToNullableDate(const aDate: INullable<TDate>);
    procedure FromNullableDate(const aDate: INullable<TDate>);
    procedure ToNullableSimpleDate(const aSimpleDate: INullable<TSimpleDate>);
    procedure FromNullableSimpleDate(const aSimpleDate: INullable<TSimpleDate>);
  end;

implementation

uses System.Math;

{ TDateEditValueHelper }

procedure TDateEditValueHelper.FromNullableDate(const aDate: INullable<TDate>);
begin
  Self.Value := aDate.Value;
  Self.Null := not aDate.HasValue or SameValue(aDate.Value, 0);
end;

procedure TDateEditValueHelper.FromNullableSimpleDate(const aSimpleDate: INullable<TSimpleDate>);
begin
  Self.Value := aSimpleDate.Value;
  Self.Null := not aSimpleDate.HasValue;
end;

procedure TDateEditValueHelper.ToNullableDate(const aDate: INullable<TDate>);
begin
  if Self.Null or not Self.Value.IsYearKnown then
    aDate.Reset
  else
    aDate.Value := Self.Value.AsDate;
end;

procedure TDateEditValueHelper.ToNullableSimpleDate(const aSimpleDate: INullable<TSimpleDate>);
begin
  if Self.Null then
    aSimpleDate.Reset
  else
    aSimpleDate.Value := Self.Value;
end;

end.

