unit Exporter.Base;

interface

uses SqlConnection, Exporter.TargetIntf;

type
  TExporterBase<T: class, constructor> = class
  strict private
    fConnection: ISqlConnection;
    fParams: T;
    fTarget: IExporterTarget<T>;
    fQuery: ISqlPreparedQuery;
    function GetSqlDataSet(out aSqlDataSet: ISqlDataSet): Boolean;
  strict protected
    procedure PrepareExport; virtual;
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; virtual;
    procedure CleanupAfterExport; virtual;
    property Connection: ISqlConnection read fConnection;
  public
    constructor Create(const aConnection: ISqlConnection; const aTarget: IExporterTarget<T>);
    destructor Destroy; override;
    procedure DoExport;
    property Params: T read fParams;
  end;

implementation

{ TExporterBase<T> }

constructor TExporterBase<T>.Create(const aConnection: ISqlConnection; const aTarget: IExporterTarget<T>);
begin
  inherited Create;
  fConnection := aConnection;
  fTarget := aTarget;
  fParams := T.Create;
end;

destructor TExporterBase<T>.Destroy;
begin
  fParams.Free;
  inherited;
end;

procedure TExporterBase<T>.DoExport;
begin
  try
    fTarget.SetParams(fParams);
    PrepareExport;
    var lDataSet: ISqlDataSet;
    if GetSqlDataSet(lDataSet) then
      fTarget.DoExport(lDataSet);
  finally
    CleanupAfterExport;
  end;
end;

procedure TExporterBase<T>.CleanupAfterExport;
begin

end;

procedure TExporterBase<T>.PrepareExport;
begin

end;

function TExporterBase<T>.CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean;
begin
  Result := False;
end;

function TExporterBase<T>.GetSqlDataSet(out aSqlDataSet: ISqlDataSet): Boolean;
begin
  Result := False;
  aSqlDataSet := nil;
  if not Assigned(fQuery) then
  begin
    if CreatePreparedQuery(fQuery) then
      fQuery.Open;
  end;
  if Assigned(fQuery) then
  begin
    aSqlDataSet := fQuery.AsSqlDataSet;
    Result := True;
  end;
end;

end.
