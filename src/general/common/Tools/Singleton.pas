unit Singleton;

interface

uses System.SysUtils;

type
  TSingletonObject<T: class> = class abstract
  strict private
    class var fInstance: T;
  strict protected
    class function CreateNewInstance: T; virtual; abstract;
  public
    class destructor ClassDestroy;
    class function Instance: T;
    class function IsInstanceCreated: Boolean;
    class procedure CallProcIfInstanceAvailable(const aProc: TProc<T>);
  end;

implementation

{ TSingletonObject<T> }

class destructor TSingletonObject<T>.ClassDestroy;
begin
  FreeAndNil(fInstance);
end;

class function TSingletonObject<T>.Instance: T;
var
  lNewValue: T;
begin
  if Assigned(fInstance) then
    Exit(fInstance);
  lNewValue := CreateNewInstance;
  var lSucceeded := False;
  AtomicCmpExchange(Pointer(fInstance), Pointer(lNewValue), nil, lSucceeded);
  if not lSucceeded then
    FreeAndNil(lNewValue);
  Result := fInstance;
end;

class function TSingletonObject<T>.IsInstanceCreated: Boolean;
begin
  Result := Assigned(fInstance);
end;

class procedure TSingletonObject<T>.CallProcIfInstanceAvailable(const aProc: TProc<T>);
begin
  if IsInstanceCreated then
    aProc(fInstance);
end;

end.
