# SpaceMission 1.2 Dokumentation

Bitte auch lesen: [Was ist neu in Version 1.2?](Neuerungen.md)

## Beschreibung
SpaceMission ist ein klassisches Weltraumspiel, beidem Sie durch einen Kometenhagel fliegen,
UFOs und andere Raumschiffe abschießen müssen. Es gibt seit Version 1.1 31 Levels, die
von meinen Mitarbeitern erstellt wurden. Außerdem gibt es Zufallslevels, das heißt, dass Levels
vom Computer durch Zufall erstellt werden. Diese Zufallslevels sind besonders gut. In der
Version 1.1 gibt es nun auch einen neuen Leveleditor, mit denen Sie Ihre eigenen Levels
erstellen können. Viel Spaß mit SpaceMission.

### Gute Levels gesucht:
Wenn Sie gute Levels erstellt haben und diese in der nächsten Version veröffentlichen möchten,
senden Sie sie bitte per E-Mail an info@daniel-marschall.de

## Bedienung/Steuerung
### SpaceMission
Im Menü wählen Sie den Menüpunkt mit den Pfeiltasten aus. Drücken Sie die Leertaste,
um fortzufahren. Im Spiel steuern Sie das Raumschiff mit den Pfeiltasten. Mit der
Leertaste schießen Sie.

### Leveleditor
Wählen Sie rechts einen Einheitentyp aus, unten können Sie die Leben einstellen.
Kometen sind unzerstörbar und haben somit keine Leben. Anschließend setzen Sie mit
der Linken Maustaste eine Einheit auf das Spielfeld. Klicken Sie mit der rechten
Maustaste auf eine Einheit, um sie zu löschen. Wenn Sie die Leben einer Einheit löschen
möchten, müssen Sie sie löschen und wieder neu setzen.

## Quelltext
Der Quelltext des Spiels ist öffentlich. SpaceMission kann von jedem verändert
oder weiterentwickelt werden. Voraussetzung ist die Programmier-Umgebung Embarcadero Delphi.

Quelltext unter www.github.com/danielmarschall/spacemission


## Aufbau von Spielstand- und Leveldateien
Savegame- und Level-Dateien teilen das gleiche Format; eine Savedatei ist eine erweiterte Leveldatei.

[Beschreibung der OID auf OIDplus](https://hosted.oidplus.com/viathinksoft/?goto=oid%3A1.3.6.1.4.1.37476.2.8.1.1)

    [1.3.6.1.4.1.37476.2.8.1.1]
    Score  ...  (nur vorhanden wenn Datei ein Spielstand ist)
    Lives  ...  (nur vorhanden wenn Datei ein Spielstand ist)
    Level  ...  (nur vorhanden wenn Datei ein Spielstand ist)
    Mode   ...  (nur vorhanden wenn Datei ein Spielstand ist; 1=Normal, 2=Zufall)
    Name   ...
    Author ...
    Width  ...  (Standard 1200; nur für Leveleditor relevant)
    Enemy  <Typ> <XCoord> <YCoord> <Leben>
    Enemy  <Typ> <XCoord> <YCoord> <Leben>; Kommentarzeile am Ende einer Gegner-Zeile
    Enemy  <Typ> <XCoord> <YCoord> <Leben>
    Enemy  ...
    ; Kommentar-Zeile

Anmerkungen:
- Alle Level-Dateien müssen den Namen "Level [Level-Nr].lev" haben, bzw. alle Spielstanddateien müssen "[Name].sav" lauten.
- Die Reihenfolge der Zeilen ist beliebig. Die erste Zeile muss jedoch exakt stimmen.
- Leere Zeilen sind erlaubt
- Enemy `<Typ>` = Gegner Typ (1=Attacker, 2=Attacker2, 3=Attacker3, 4=Meteor, 5=UFO, 6=UFO2, 7=Boss, 8=Medikit)
- Enemy `<XCoord>` = Gegner X-Koordinate (muss durch 48 teilbar sein, wenn Level mit Leveleditor bearbeitet werden soll)
- Enemy `<YCoord>` = Gegner Y-Koordinate (muss durch 32 teilbar sein, wenn Level mit Leveleditor bearbeitet werden soll)
- Enemy `<Leben>` = Gegner Leben (keine relevanz für Kometen)

## Cheat

Bitte beachten Sie, dass die Verwendung von Cheats Ihnen den Spielspaß verderben kann!

Wenn Sie dennoch Cheats anwenden möchten:

- Cheat für unendliche Leben: Countrysänger der "Man in Black" in 1971 veröffentlicht hat.

## Lizenzbedingungen

Lizenziert unter den Bedingungen der Apache 2.0 Lizenz,
d.h. die Weitergabe ist ausdrücklich erwünscht!

## Autor

Homepage: www.daniel-marschall.de
E-Mail:  info@daniel-marschall.de