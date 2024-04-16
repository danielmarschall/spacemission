# SpaceMission 1.2 Dokumentation

## Beschreibung
SpaceMission ist ein klassisches Weltraumspiel, beidem Sie durch einen Kometenhagel fliegen,
UFOs und andere Raumschiffe abschießen müssen. Es gibt seit Version 1.1 31 Levels, die
von meinen Mitarbeitern erstellt wurden. Außerdem gibt es Zufallslevels, das heißt, dass Levels
vom Computer durch Zufall erstellt werden. Diese Zufallslevels sind besonders gut. In der
Version 1.1 gibt es nun auch einen neuen Leveleditor, mit denen Sie Ihre eigenen Levels
erstellen können. Viel Spaß mit SpaceMission.

## Gute Levels gesucht:
Wenn Sie gute Levels erstellt haben und diese in der nächsten Version veröffentlichen möchten, senden
Sie sie bitte per E-Mail an info@daniel-marschall.de . Wenn Sie gut sind, werde ich sie
veröffentlichen.

## Bedienung:

### SpaceMission:
Im Menü wählen Sie den Menüpunkt mit den Pfeiltasten aus. Drücken Sie die Leertaste,
um fortzufahren.Im Spiel steuern Sie das Raumschiff mit den Pfeiltasten. Mit der
Leertaste schießen Sie.

### Leveleditor:
Wählen Sie rechts einen Einheitentyp aus, unten können Sie die Leben einstellen.
Kometen sind unzerstörbar und haben somit keine Leben. Anschließend setzen Sie mit
der Linken Maustaste eine Einheit auf das Spielfeld. Klicken Sie mit der rechten
Maustaste auf eine Einheit, um sie zu löschen. Wenn Sie die Leben einer Einheit löschen
möchten, müssen Sie sie löschen und wieder neu setzen.

## Mitwirkende:

Programmierung:
- Daniel Marschall

Levels:
- Patrick Büssecker
- Andreas Kübelsbeck
- Daniel Marschall

Beispiel & Ressourcen:
- Hiroyuki Hori

Sprachunterstützung:
- Borland (Turbo Delphi Explorer)
- Hiroyuki Hori (DelphiX 2000)
- InnoSetup (Setup)

Grafik:
- Daniel Marschall
- SW-Software
- Hiroyuki Hori
- Creative
- MD-Technologie

Sound:
- SW-Software
- Hiroyuki Hori
- Garfield

Musik:
- Savage Peachers Software

Programmsymbole:
- Daniel Marschall
- Hutchins
- Westwood
- Borland

Das Programm wurde mit Delphi 6 Personal entwickelt und wurde mit einigen VCLs
verbessert! Das Installationsprogramm wurde mit InnoSetup erstellt.

## Aufbau von Leveldateien:

[Beschreibung auf OIDplus](https://hosted.oidplus.com/viathinksoft/?goto=oid%3A1.3.6.1.4.1.37476.2.8.1.1)

    [1.3.6.1.4.1.37476.2.8.1.1]
    Name   ...
    Author ...
    Width  ... (Standard 1200; nur für Leveleditor relevant)
    Enemy  <Typ> <XCoord> <YCoord> <Leben>
    Enemy  <Typ> <XCoord> <YCoord> <Leben>; Kommentarzeile am Ende einer Gegner-Zeile
    Enemy  <Typ> <XCoord> <YCoord> <Leben>
    Enemy  ...
    ; Kommentar-Zeile

Anmerkungen:
- Alle Dateien müssen den Namen "Level [Level-Nr].lev" haben.
- Die Reihenfolge der Zeilen ist beliebig. Die erste Zeile muss jedoch exakt stimmen.
- Leere Zeilen sind erlaubt
- Enemy `<Typ>` = Gegner Typ (1=Attacker, 2=Attacker2, 3=Attacker3, 4=Meteor, 5=UFO, 6=UFO2, 7=Boss)
- Enemy `<XCoord>` = Gegner X-Koordinate (muss durch 48 teilbar sein, wenn Level mit Leveleditor bearbeitet werden soll)
- Enemy `<YCoord>` = Gegner Y-Koordinate (muss durch 32 teilbar sein, wenn Level mit Leveleditor bearbeitet werden soll)
- Enemy `<Leben>` = Gegner Leben (keine relevanz für Kometen)

## Aufbau von Spielständen:

[Beschreibung auf OIDplus](https://hosted.oidplus.com/viathinksoft/?goto=oid%3A1.3.6.1.4.1.37476.2.8.1.1)

    [1.3.6.1.4.1.37476.2.8.1.1]
    Score  3000
    Lives  6
    Level  1
    Mode   2   (1=Normal, 2=Zufall)
    Name   ... (des Levels)
    Author ... (des Levels)
    Width  ...
    Enemy  ...		
    ; Kommentar-Zeile

Anmerkungen:
- Alle Dateien müssen den Namen "[Name].sav" haben.
- Die Reihenfolge der Zeilen ist fest vorgegeben. Die erste Zeile muss exakt stimmen.
- Leere Zeilen sind erlaubt
- Eine Savedatei ist eine erweiterte Leveldatei. Die Gegner müssen nicht zwingend auf dem Raster 48/32 liegen.

## License

Licensed under the terms of the Apache 2.0 license.

## Author

Homepage: http://www.daniel-marschall.de/
E-Mail: info@daniel-marschall.de