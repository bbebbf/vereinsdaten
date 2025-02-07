unit ProgressIndicatorIntf;

interface

uses InterfacedBase;

type
  IProgressIndicator = interface
    ['{BE3F280D-F437-4ECC-88B2-C49F8284C15C}']
    procedure ProgressBegin(const aWorkCount: Integer; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer);
    procedure ProgressEnd;
    procedure ProgressText(const aText: string);
  end;

  TProgress = class(TInterfacedBase, IProgressIndicator)
  strict private
    fIndicator: IProgressIndicator;
    procedure ProgressBegin(const aWorkCount: Integer; const aText: string = '');
    procedure ProgressStep(const aStepCount: Integer);
    procedure ProgressEnd;
    procedure ProgressText(const aText: string);
    constructor Create(const aIndicator: IProgressIndicator;
      const aWorkCount: Integer; const aText: string);
  public
    class function New(const aIndicator: IProgressIndicator;
      const aWorkCount: Integer; const aText: string = ''): IProgressIndicator;
    destructor Destroy; override;
  end;

implementation

{ TProgress }

destructor TProgress.Destroy;
begin
  ProgressEnd;
  inherited;
end;

class function TProgress.New(const aIndicator: IProgressIndicator; const aWorkCount: Integer;
  const aText: string): IProgressIndicator;
begin
  Result := TProgress.Create(aIndicator, aWorkCount, aText);
end;

constructor TProgress.Create(const aIndicator: IProgressIndicator; const aWorkCount: Integer;
  const aText: string);
begin
  inherited Create;
  fIndicator := aIndicator;
  ProgressBegin(aWorkCount, aText);
end;

procedure TProgress.ProgressBegin(const aWorkCount: Integer; const aText: string);
begin
  if Assigned(fIndicator) then
    fIndicator.ProgressBegin(aWorkCount, aText);
end;

procedure TProgress.ProgressEnd;
begin
  if Assigned(fIndicator) then
    fIndicator.ProgressEnd;
end;

procedure TProgress.ProgressStep(const aStepCount: Integer);
begin
  if Assigned(fIndicator) then
    fIndicator.ProgressStep(aStepCount);
end;

procedure TProgress.ProgressText(const aText: string);
begin
  if Assigned(fIndicator) then
    fIndicator.ProgressText(aText);
end;

end.
