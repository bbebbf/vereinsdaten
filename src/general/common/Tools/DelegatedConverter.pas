unit DelegatedConverter;

interface

uses InterfacedBase, ValueConverter;

type
  TDelegatedConverterProc<S, T> = reference to procedure(const aValue: S; var aTarget: T);

  TDelegatedConverter<S, T> = class(TInterfacedBase, IValueConverter<S, T>)
  strict private
    fConvert: TDelegatedConverterProc<S, T>;
    fConvertBack: TDelegatedConverterProc<T, S>;
    procedure Convert(const aValue: S; var aTarget: T);
    procedure ConvertBack(const aValue: T; var aTarget: S);
  public
    constructor Create(const aConvert: TDelegatedConverterProc<S, T>;
      const aConvertBack: TDelegatedConverterProc<T, S>);
  end;

implementation

{ TDelegatedConverter<S, T> }

constructor TDelegatedConverter<S, T>.Create(const aConvert: TDelegatedConverterProc<S, T>;
  const aConvertBack: TDelegatedConverterProc<T, S>);
begin
  inherited Create;
  fConvert := aConvert;
  fConvertBack := aConvertBack;
end;

procedure TDelegatedConverter<S, T>.Convert(const aValue: S; var aTarget: T);
begin
  fConvert(aValue, aTarget);
end;

procedure TDelegatedConverter<S, T>.ConvertBack(const aValue: T; var aTarget: S);
begin
  fConvertBack(aValue, aTarget);
end;

end.
