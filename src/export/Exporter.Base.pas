unit Exporter.Base;

interface

uses System.Generics.Collections, SqlConnection, Exporter.TargetIntf, ParamsProvider;

type
  TExporterBase<T: class, constructor> = class
  strict private
    fConnection: ISqlConnection;
    fParams: T;
    fOwnsParams: Boolean;
    fParamsProvider: IParamsProvider<T>;
    fTargets: TList<IExporterTarget<T>>;
    fQuery: ISqlPreparedQuery;
    fTemporaryTableNames: TStack<string>;
    function GetSqlDataSet(out aSqlDataSet: ISqlDataSet): Boolean;
    procedure SetParams(const aValue: T);
    procedure SetTargetsToParamsProvider;
  strict protected
    procedure PrepareExport; virtual;
    function CreatePreparedQuery(out aQuery: ISqlPreparedQuery): Boolean; virtual;
    procedure CleanupAfterExport; virtual;
    function CreateTemporaryTable(const aColumnsDDLs: string): string;
    procedure DropAllTemporaryTables;

    property Connection: ISqlConnection read fConnection;
  public
    constructor Create(const aConnection: ISqlConnection);
    destructor Destroy; override;
    function DoExport: Boolean;
    property Targets: TList<IExporterTarget<T>> read fTargets;
    property Params: T read fParams write SetParams;
    property ParamsProvider: IParamsProvider<T> read fParamsProvider write fParamsProvider;
  end;

implementation

uses System.IOUtils;

{ TExporterBase<T> }

constructor TExporterBase<T>.Create(const aConnection: ISqlConnection);
begin
  inherited Create;
  fTargets := TList<IExporterTarget<T>>.Create;
  fTemporaryTableNames := TStack<string>.Create;
  fConnection := aConnection;
  fParams := T.Create;
  fOwnsParams := True;
end;

destructor TExporterBase<T>.Destroy;
begin
  if fOwnsParams then
    fParams.Free;
  fTemporaryTableNames.Free;
  fTargets.Free;
  inherited;
end;

function TExporterBase<T>.DoExport: Boolean;
begin
  Result := False;
  if fTargets.Count = 0 then
    Exit;

  var lTargetIndex: Integer;
  if Assigned(fParamsProvider) then
  begin
    SetTargetsToParamsProvider;
    fParamsProvider.SetParams(fParams);
    if fParamsProvider.ProvideParams then
    begin
      lTargetIndex := fParamsProvider.GetTargetIndex;
      fParamsProvider.GetParams(fParams);
      if not fParamsProvider.ShouldBeExported(fParams) then
        Exit;
    end
    else
    begin
      Exit;
    end;
  end
  else
  begin
    lTargetIndex := 0;
  end;
  if lTargetIndex < 0 then
    Exit;

  try
    fTargets[lTargetIndex].SetParams(fParams);
    PrepareExport;
    var lDataSet: ISqlDataSet;
    if GetSqlDataSet(lDataSet) then
    begin
      fTargets[lTargetIndex].DoExport(lDataSet);
      Result := True;
    end;
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

procedure TExporterBase<T>.SetParams(const aValue: T);
begin
  if (fParams = aValue) or not Assigned(aValue) then
    Exit;
  fParams.Free;
  fParams := aValue;
  fOwnsParams := False;
end;

procedure TExporterBase<T>.SetTargetsToParamsProvider;
begin
  var lTargetTitles: TArray<string> := [];
  SetLength(lTargetTitles, fTargets.Count);
  for var i := 0 to fTargets.Count - 1 do
    lTargetTitles[i] := fTargets[i].Title;
  fParamsProvider.SetTargets(lTargetTitles);
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
