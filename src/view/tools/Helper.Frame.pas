unit Helper.Frame;

interface

uses Vcl.Forms, Vcl.Controls;

type
  TFrameHelper = class helper for TFrame
  public
    function GetForm: TForm;
  end;

implementation

{ TFrameHelper }

function TFrameHelper.GetForm: TForm;
begin
  Result := nil;
  var lParent := Self.Parent;
  while Assigned(lParent) do
  begin
    if lParent is TForm then
      Exit((lParent as TForm));
    lParent := lParent.Parent;
  end;
end;

end.
