unit CsvWriter;

interface

uses System.Classes, System.SysUtils, InterfacedBase;

type
  ICsvWriter = interface
    ['{AF4A1B46-BEE2-41C6-9E23-D067B4FD8E43}']
    function AddValue(const aValue: string): ICsvWriter; overload;
    function AddValue(const aValue: Int64): ICsvWriter; overload;
    function AddValue(const aValue: Boolean): ICsvWriter; overload;
    function AddValue(const aValue: Extended): ICsvWriter; overload;
    function AddValue(const aValue: Extended; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: Extended): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: Extended; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: TDateTime): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: TDateTime; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aValue: Variant): ICsvWriter; overload;
    function NewLine: ICsvWriter;
    function Close: ICsvWriter;
    function GetLineCount: Integer;
    function GetValueCount: Integer;
  end;

  TCsvWriter = class(TInterfacedBase, ICsvWriter)
  strict private
    fStream: TStreamWriter;
    fCurrentLine: string;
    fLineCount: Integer;
    fFirstLineValueCount: Integer;
    fCurrentLineValueCount: Integer;

    procedure WriteCurrentLine;

    function AddValue(const aValue: string): ICsvWriter; overload;
    function AddValue(const aValue: Int64): ICsvWriter; overload;
    function AddValue(const aValue: Boolean): ICsvWriter; overload;
    function AddValue(const aValue: Extended): ICsvWriter; overload;
    function AddValue(const aValue: Extended; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: Extended): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: Extended; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: TDateTime): ICsvWriter; overload;
    function AddValue(const aFormat: string; const aValue: TDateTime; const aFormatSettings: TFormatSettings): ICsvWriter; overload;
    function AddValue(const aValue: Variant): ICsvWriter; overload;
    function NewLine: ICsvWriter;
    function Close: ICsvWriter;
    function GetLineCount: Integer;
    function GetValueCount: Integer;

    constructor Create(const aOutputStream: TStream);
  public
    class function GetInstance(const aOutputStream: TStream): ICsvWriter;
    destructor Destroy; override;
  end;

implementation

uses System.Variants;

{ TCsvWriter }

class function TCsvWriter.GetInstance(const aOutputStream: TStream): ICsvWriter;
begin
  Result := TCsvWriter.Create(aOutputStream);
end;

constructor TCsvWriter.Create(const aOutputStream: TStream);
begin
  inherited Create;
  fStream := TStreamWriter.Create(aOutputStream);
end;

destructor TCsvWriter.Destroy;
begin
  Close;
  fStream.Free;
  inherited;
end;

function TCsvWriter.GetLineCount: Integer;
begin
  Result := fLineCount;
end;

function TCsvWriter.GetValueCount: Integer;
begin
  Result := fFirstLineValueCount;
end;

function TCsvWriter.AddValue(const aFormat: string; const aValue: Extended;
  const aFormatSettings: TFormatSettings): ICsvWriter;
begin
  Result := AddValue(FormatFloat(aFormat, aValue, aFormatSettings));
end;

function TCsvWriter.AddValue(const aFormat: string; const aValue: Extended): ICsvWriter;
begin
  Result := AddValue(FormatFloat(aFormat, aValue));
end;

function TCsvWriter.AddValue(const aValue: Extended; const aFormatSettings: TFormatSettings): ICsvWriter;
begin
  Result := AddValue(FloatToStr(aValue, aFormatSettings));
end;

function TCsvWriter.AddValue(const aValue: Extended): ICsvWriter;
begin
  Result := AddValue(FloatToStr(aValue));
end;

function TCsvWriter.AddValue(const aFormat: string; const aValue: TDateTime; const aFormatSettings: TFormatSettings): ICsvWriter;
begin
  Result := AddValue(FormatDateTime(aFormat, aValue, aFormatSettings));
end;

function TCsvWriter.AddValue(const aFormat: string; const aValue: TDateTime): ICsvWriter;
begin
  Result := AddValue(FormatDateTime(aFormat, aValue));
end;

function TCsvWriter.AddValue(const aValue: Int64): ICsvWriter;
begin
  Result := AddValue(IntToStr(aValue));
end;

function TCsvWriter.AddValue(const aValue: Boolean): ICsvWriter;
begin
  Result := AddValue(BoolToStr(aValue));
end;

function TCsvWriter.AddValue(const aValue: Variant): ICsvWriter;
begin
  Result := AddValue(VarToStr(aValue));
end;

function TCsvWriter.AddValue(const aValue: string): ICsvWriter;
begin
  Result := Self;
  if fCurrentLineValueCount = 0 then
    Inc(fLineCount)
  else
    fCurrentLine := fCurrentLine + ';';

  fCurrentLine := fCurrentLine + '"';
  for var lChar in aValue do
  begin
    if lChar = '"' then
      fCurrentLine := fCurrentLine + '"';
    fCurrentLine := fCurrentLine + lChar;
  end;
  fCurrentLine := fCurrentLine + '"';
  Inc(fCurrentLineValueCount);
end;

function TCsvWriter.Close: ICsvWriter;
begin
  Result := Self;
  if fCurrentLineValueCount > 0 then
    WriteCurrentLine;
end;

function TCsvWriter.NewLine: ICsvWriter;
begin
  Result := Self;
  WriteCurrentLine;
end;

procedure TCsvWriter.WriteCurrentLine;
begin
  if fLineCount = 1 then
  begin
    fFirstLineValueCount := fCurrentLineValueCount;
  end
  else if fFirstLineValueCount <> fCurrentLineValueCount then
  begin
    raise Exception.CreateFmt('Current value count %d differs from first line value count %d.',
      [fCurrentLineValueCount, fFirstLineValueCount]);
  end;

  if fLineCount > 1 then
  begin
    fStream.WriteLine;
  end;
  fStream.Write(fCurrentLine);
  fStream.Flush;
  fCurrentLine := '';
  fCurrentLineValueCount := 0;
end;

end.
