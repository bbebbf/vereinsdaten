unit Exporter.Base;

interface

uses System.Generics.Collections, SqlConnection, Exporter.TargetIntf;

type
  TExporterBase<T: class, constructor> = class
  strict private
    fConnection: ISqlConnection;
    fParams: T;
    fTarget: IExporterTarget<T>;
    fQuery: ISqlPreparedQuery;
    fTemporaryTableNames: TStack<string>;
    function GetSqlDataSet(out aSqlDataSet: ISqlDataSet): Boolean;
  strict protected
    procedure PrepareExport; virtual;
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; virtual;
    procedure CleanupAfterExport; virtual;
    function CreateTemporaryTable(const aColumnsDDLs: string): string;
    procedure DropAllTemporaryTables;

    property Connection: ISqlConnection read fConnection;
  public
    constructor Create(const aConnection: ISqlConnection; const aTarget: IExporterTarget<T>);
    destructor Destroy; override;
    procedure DoExport;
    property Params: T read fParams;
  end;

implementation

uses System.IOUtils;

{ TExporterBase<T> }

constructor TExporterBase<T>.Create(const aConnection: ISqlConnection; const aTarget: IExporterTarget<T>);
begin
  inherited Create;
  fTemporaryTableNames := TStack<string>.Create;
  fConnection := aConnection;
  fTarget := aTarget;
  fParams := T.Create;
end;

destructor TExporterBase<T>.Destroy;
begin
  fParams.Free;
  fTemporaryTableNames.Free;
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
    DropAllTemporaryTables;
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

function TExporterBase<T>.CreateTemporaryTable(const aColumnsDDLs: string): string;
begin
  Result := ClassName + '_' + TPath.GetGUIDFileName;
  Connection.ExecuteCommand('create temporary table ' + Result + '(' + aColumnsDDLs + ')');
  fTemporaryTableNames.Push(Result);
end;

procedure TExporterBase<T>.DropAllTemporaryTables;
begin
  while fTemporaryTableNames.Count > 0 do
    Connection.ExecuteCommand('drop temporary table if exists ' + fTemporaryTableNames.Pop);
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
