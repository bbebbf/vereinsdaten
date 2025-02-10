# Vereinsdaten

## Komponenten und Installation

- **Vdm.exe**
Hauptprogramm

- **Mysql/MariaDB-Datenbanktreiber**
z.B. libmariadb.dll

- **Ssh.exe**
Optional wird die Verbindung zur Datenbank durch einen SSH-Tunnel hergestellt. 


## Programmteile

### Personen und Einheiten

In Vdm geht es hauptsächlich darum Personen verschiedenen Einheiten zuzuordnen. Eine Einheit ist z.B. "Vorstand", und alle Vorstandsmitglieder sind dem "Vorstand" zugeordnet.

Dazu kann man für jede dieser Verbindungen zwischen Person und Einheit eine Rolle festlegen. Typische Rollen für den Vorstand wären "Vorsitz", "stellvertr. Vorsitz" oder "Kasse".

### Stammdaten erfassen / bearbeiten

#### Personendaten

- allgemeine Personendaten
- Aktiv: Ja/Nein
- Adressdaten
- Daten zur Vereinsmitgliedschaft

#### Adressen

Adressen sind separat gespeichert und werden Personen zugeordnet. Dadurch wird die Wahrscheinlichkeit von Rechschreibfehlern in Adressdaten reduziert. z.B. kann man Familienmitgliedern dieselbe Adresse zuordnen.

#### Einheiten

- Bezeichnung
- Aktiv: Ja/Nein
- Aktiver Zeitraum: Von/Bis
- Datum "Datum bestätigt am"

#### Rollen

- Bezeichnung
- Sortierung

### Berichte

- Einheiten und Personen
- Rollen und Einheiten
- Personen und Einheiten
- Personen
- Vereinsmitglieder
