
# SpaceMission TODO

Geplant für 1.2:
- !!! Großes Problem: "Levels" Ordner wird in Program Files sein und ist damit unveränderbar. Aber wo werden die Benutzer ihr Level hinspeichern können?
- Leveleditor "Testen" Button, um die Mission gleich zu testen
- Spielstände sollten die Level-Information beinhalten (also TLevelData), sodass man weiß, bei welchem Level man weiterspielen muss
	also am besten eine ".lev" datei speichern anstelle einer ".sav" datei, mit den zusatzinfos "punkte,level,leben,modus"

PROBLEM:
- PROBLEM: große level: da ist ewig lang nix!

Kleinigkeiten:
- Es wäre schön, wenn die größe der Spezialhintergründe (Planeten) abhängig von wäre, wie weit entfernt sie ist (Layer 1,2,3)
- wenn man getroffen ist, sollte man blinken, sodass man sieht, ab wann man wieder verwundbar ist

--- 

2024 Review:
- GitHub MarkDown Dokumente auch in Spacemission anzeigen, vielleicht in einem TMemo
- Release 1.2 with EV CodeSign
- Neue Einheit: Medikit
- Neue Einheit: Ufo, das im Kreis fliegt und nicht weggeht
- Bei Pause => Entweder alles grau werden lassen
- Alle Notizen durchschauen
- Boss schwieriger machen: Er soll auch nach links und rechts gehen?
- Cooldown für Laser?
- Improve Sound effects
- Level-Editor in die SpaceMission.exe rein und über Hauptmenü aufrufen?
- "Doku" in Hilfemenü einbinden, ggf. auch den Leveleditor ins Menü machen
- Highscore Liste
- Multilingual (all strings in resourcestrings)
- Was ist wenn man mission erfolgreich hatte und dann doch stirbt?
- Schrift rechts (Boss: X) soll rechtsbündig sein

2015 Review:
- (siehe NOT): weitere Änderungen?
- bewegungsunschärfe wegen TFT
- "Throwback" nach einem hit
- weniger startmenüeinträge wegen windows 10
- versioninfo
- Bug: 2 Taskleisteneinträge
- Multilingual
- SplashScreens: als BMP
- Intro : Enter anstelle Leertaste
- Pause : Bildschirm soll grau werden
- Hintergrund besser und Abwechslungsreicher
- Neues DX: FPS-Limiter für Sprite-Animationen -- not a bug: liegt an spielgeschwindigkeit
- Verschiedene Schwierigkeitsstufen (Geschwindigkeiten)
- Boss schwieriger machen
- Neues UFO das im Kreis fliegt
- Endloses Zufallsspiel
- Full screen bug beheben + Skalierung verbessern
- Medikits, Unverwundbarkeits-Items
- Limitierung der Schüsse (Kanone wird heiß)
- Bessere Sounds
- Quellcode optimieren, keine Compilerwarnungen mehr
- Levels besser machen
- Ordnerstruktur vereinfachen (nicht für alles einen Unterordner)
- Nicht mehr auf die Existenz jeder einzelnen Datei prüfen
- InnoSetup: Nicht mehr so viele Verknüpfungen (wegen Win10)
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)

SPIEL:
- Nach Treffer, zurückgeschleudert werden
- Vollbildwechsel geht nicht
- Tastenspeere bei runter+links+shot
- Schutzverletzung bei Spielstände aufr

LEVELEDITOR:
- Kartengröße bleibt bei "Neu"
- "Beenden ohne Speichern?" bei leerem Level
- Langsam, manchmal sogar Deadlock
- ggf. auch Autor in LVL Datei packen und Kommentare in Datei erlauben
- Delphi IDE: Form Height ändern sich automatisch, es wird immer größer.
