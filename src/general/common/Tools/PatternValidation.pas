unit PatternValidation;

interface

type
  TPatternValidation = class
  public
    class function IsEmailAddressValid(const aEmailAddress: string): Boolean;
    class function IsPhoneNumberValid(const aPhoneNumber: string): Boolean;
  end;

implementation

uses System.RegularExpressions;

{ TPatternValidation }

class function TPatternValidation.IsEmailAddressValid(const aEmailAddress: string): Boolean;
begin
  var lRegEx := TRegEx.Create('^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  Result := lRegEx.Match(aEmailAddress).Success;
end;

class function TPatternValidation.IsPhoneNumberValid(const aPhoneNumber: string): Boolean;
begin
  Result := True;
end;

end.
