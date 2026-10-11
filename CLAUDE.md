# CLAUDE.md

Vereinsdaten-Manager (`Vdm.exe`): Delphi-VCL-Desktopanwendung zur Verwaltung von Personen, Einheiten (z.B. "Vorstand"), Rollen, Adressen und Vereinsmitgliedschaften in einer MySQL/MariaDB-Datenbank. Oberfläche, Bezeichner in der UI und Commit-Messages sind Deutsch; Code-Bezeichner Englisch.

## Build und Tests

- Delphi-Projekte (RAD Studio, Win32/Win64): `src/Vereinsdaten.groupproj` enthält `vdm.dproj` (App) und `vdmTests.dproj` (DUnitX-Konsolen-Tests).
- Build per Kommandozeile (RAD Studio Eingabeaufforderung / `rsvars.bat` geladen): `msbuild src\vdm.dproj /p:Config=Debug /p:Platform=Win32`
- Tests: `msbuild src\vdmTests.dproj`, dann `out\bin\Win32\Debug\vdmTests.exe`. Testeinheiten liegen in `src/tests/` und müssen zusätzlich in `vdmTests.dpr` eingetragen werden.
- Ausgabe: `out\bin\<Platform>\<Config>`, DCUs in `out\dcu\...` (nicht versioniert).
- Post-Build-Schritt (`build/post-build-release.ps1`) kopiert `libmariadb.dll` und `ssh.exe` aus `src/3rdparty/mysql/dll` bzw. `src/3rdparty/OpenSSH` ins Ausgabeverzeichnis; schlägt fehl, wenn sie fehlen (`*.dll` ist in `.gitignore`).
- Defines: `DEBUG` + `INTERNAL_DB_ID_VISIBLE` (Debug), `RELEASE`, `FastMM` (nutzt `src/3rdparty/FastMM`). Gemeinsame Direktiven in `src/inc/CompilerDirectives.inc`.
- Externe Abhängigkeit: Unit-Suchpfad `..\..\ConstraintControls\ConstraintControls` (separates Repo neben diesem; liegt außerhalb von `vereinsdaten`).
- Neue Units müssen in der jeweiligen `.dpr` (`uses ... in '...'`) eingetragen werden – Delphi nutzt hier keine Suchpfad-Auflösung für Projekt-Units.

## Datenbank und Konfiguration

- Schema: `sql/mysql-database-create.sql` (Tabellen `person`, `clubmembership`, `address`, `person_address`, `unit`, `role`, `member`, `tenant`, `version_info`). Spaltennamen haben Tabellenpräfix (`person_`, `clmb_`, `adr_`, `unit_`).
- Lokale Test-DB + SSH-Server: `docker/docker-compose.yml` (MariaDB 10.11, Port 8306; Variablen `DB_*`, `TZ`, `SSH_*` aus `.env`).
- Laufzeitkonfiguration: INI-Datei `%LOCALAPPDATA%\BBE\<exe-name>\<exe-name>.ini` (`TConfigReader`). Pro Verbindung eine Sektion (`DatabaseHost`, `DatabasePort`, `DatabaseUserName`, `DatabaseUserPassword`, `DatabaseName`, optional `SshServerHost/-Port`, `SshLocalTunnelPort`, `ShapeColor`) sowie Logging-Einstellungen (Level, Targets). Fehlt die Datei, werden Beispieleinträge geschrieben.
- Optionaler SSH-Tunnel über `ssh.exe` (`SshTunnel`, `SshTunnelSqlConnection`).

## Architektur (`src/`)

Schichten, Abhängigkeiten laufen über Interfaces:

- `general/intf/` – abstrakte Schnittstellen (CRUD, SQL, Transaktion, Tools, UI-Callbacks).
- `general/common/` – generische Implementierungen: `Crud/` (CrudAccessor, ListCrudCommands), `Db/` (ConnectionFactory, ListSelector, FilterSelect), `MySql/` (FireDAC), `SshTunnelSql/`, `Tools/` (Logging, CSV, Singleton, Nullable, SqlConditionBuilder, Windows-Prozesse u.a.).
- `data/` – DTO-Records (`Dto*.pas`) und deren Mapping auf SQL (`CrudConfig*.pas`: Tabellenname, Identity-Spalten, Select-SQL, Setzen der Parameter, Lesen der Ergebnisse).
- `business/intf` + `business/impl` – Anwendungslogik. `TCrudBusiness<TEntry,TListEntry,TId,TListFilter>` ist die generische CRUD-Steuerung zwischen `ICrudUI` und `IEntryCrudConfig`; `PersonBusiness`, `MemberOfBusiness`, `MainBusiness` für Spezialfälle. `*Mapper.pas` sind Singletons, die ID→Name-Listen cachen.
- `view/` – VCL: `forms/`, `frames/` (`unPerson`, `unUnit`, `unMemberOf`), `intf/` (UI-Interfaces, die die Business-Schicht sieht), `tools/`. Dateien heißen `un<Name>.pas/.dfm`.
- `export/` + `reports/` – Berichte: `Exporter.*` ermitteln die Daten, `Report.*.Csv` und `Report.*.Printout` (Druckvorschau, `.dfm`) rendern sie; Parameterdialoge in `view/forms/export`.
- `Vdm.*.pas` in `general/` – anwendungsspezifische Globals, Typen, Logging-Setup, Versionierungstypen.

Neue Entität typischerweise: `Dto<X>` + `CrudConfig<X>` in `data/`, Anbindung über `TCrudBusiness` und ein Frame/Form in `view/`.

## Konventionen

- Delphi-Stil: Typen `T…`, Interfaces `I…`, Parameter `a…`, lokale Variablen `l…`, Felder `f…`; Inline-`var` wird verwendet.
- Klassen mit Interface-Referenzzählung erben von `TInterfacedBase`.
- Dateien sind UTF-8 mit BOM; Zeilenenden und Encoding beim Bearbeiten beibehalten.
- `.dfm`-Dateien nicht von Hand umformatieren; Änderungen an Formularen lieber minimal halten.
- Logging über `TLogger` (`Logging.Intf`); Ziele: Datei, Konsole, Pipe (bis zu 3 Clients). Konfiguriert über `TVdmLogging.ApplyLoggingConfig`.
- `__history/` ist die IDE-Sicherung – ignorieren.
