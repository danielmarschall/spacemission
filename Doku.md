# SpaceMission 1.2 Dokumentation

## Beschreibung
SpaceMission ist ein klassisches Weltraumspiel, beidem Sie durch einen Kometenhagel fliegen,
UFOs und andere Raumschiffe abschie�en m�ssen. Es gibt seit Version 1.1 31 Levels, die
von meinen Mitarbeitern erstellt wurden. Au�erdem gibt es Zufallslevels, das hei�t, dass Levels
vom Computer durch Zufall erstellt werden. Diese Zufallslevels sind besonders gut. In der
Version 1.1 gibt es nun auch einen neuen Leveleditor, mit denen Sie Ihre eigenen Levels
erstellen k�nnen. Viel Spa� mit SpaceMission.

## Gute Levels gesucht:
Wenn Sie gute Levels erstellt haben und diese in der n�chsten Version ver�ffentlichen m�chten, senden
Sie sie bitte per E-Mail an info@daniel-marschall.de . Wenn Sie gut sind, werde ich sie
ver�ffentlichen.

## Bedienung:

### SpaceMission:
Im Men� w�hlen Sie den Men�punkt mit den Pfeiltasten aus. Dr�cken Sie die Leertaste,
um fortzufahren.Im Spiel steuern Sie das Raumschiff mit den Pfeiltasten. Mit der
Leertaste schie�en Sie.

### Leveleditor:
W�hlen Sie rechts einen Einheitentyp aus, unten k�nnen Sie die Leben einstellen.
Kometen sind unzerst�rbar und haben somit keine Leben. Anschlie�end setzen Sie mit
der Linken Maustaste eine Einheit auf das Spielfeld. Klicken Sie mit der rechten
Maustaste auf eine Einheit, um sie zu l�schen. Wenn Sie die Leben einer Einheit l�schen
m�chten, m�ssen Sie sie l�schen und wieder neu setzen.

## Mitwirkende:

Programmierung:
- Daniel Marschall

Levels:
- Patrick B�ssecker
- Andreas K�belsbeck
- Daniel Marschall

Beispiel & Ressourcen:
- Hiroyuki Hori

Sprachunterst�tzung:
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

    ; SpaceMission 1.0
    ; LEV-File
    L�nge der Karte (Default: 1200, nur f�r Leveleditor relevant)
    Gegner 1 Typ (1=Attacker, 2=Attacker2, 3=Attacker3, 4=Meteor, 5=UFO, 6=UFO2, 7=Boss)
    Gegner 1 X-Koordinate (muss durch 48 teilbar sein)
    Gegner 1 Y-Koordinate (muss durch 32 teilbar sein)
    Gegner 1 Leben (keine relevanz f�r Kometen)
    Gegner 2 Typ ...
    ...

Regeln f�r die Leveldateien: Alle Dateien m�ssen den Namen �Level [Level-Nr].lev� haben. [L / S]*

## Aufbau von Spielst�nden:

    ; SpaceMission 1.0
    ; SAV-File
    Punkte
    Leben
    Levelnummer
    Spielart (1=Normal, 2=Zufall)

## License

Licensed under the terms of the Apache 2.0 license.

## Author

Homepage: http://www.daniel-marschall.de/
E-Mail: info@daniel-marschall.de