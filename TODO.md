
# SpaceMission TODO

Geplant für 1.2:
- !!! Großes Problem: "Levels" Ordner wird in Program Files sein und ist damit unveränderbar. Aber wo werden die Benutzer ihr Level hinspeichern können?
			Hier am besten so vorgehen:
			LEV+SAV Auflistungen: Zuerst gucken, ob eine Leveldatei mit der Levelnummer in "MyGames" liegt, und ansonsten bei "ProgramFiles" gucken
			"MyGames" überschreibt somit "ProgramFiles" in der Logik
			Bei Auflistungen müssen "MyGames" und "ProgramFiles" beide ausgelesen und vereint werden
- Leveleditor "Testen" Button, um die Mission gleich zu testen (dieser erstellt am besten eine temporäre ".sav" datei, die per commandline mit SpaceMission.exe aufgerufen wird)

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
- Multilingual
- SplashScreens: als BMP
- Pause : Bildschirm soll grau werden
- Hintergrund besser und Abwechslungsreicher
- Neues DX: FPS-Limiter für Sprite-Animationen -- not a bug: liegt an spielgeschwindigkeit
- Boss schwieriger machen
- Neues UFO das im Kreis fliegt
- Full screen bug beheben + Skalierung verbessern
- Medikits, Unverwundbarkeits-Items
- Limitierung der Schüsse (Kanone wird heiß)
- Bessere Sounds
- Levels besser machen
- InnoSetup: Nicht mehr so viele Verknüpfungen (wegen Win10)
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)

SPIEL:
- Nach Treffer, zurückgeschleudert werden
- Tastenspeere bei runter+links+shot
- Schutzverletzung bei Spielstände aufr

LEVELEDITOR:
- Kartengröße bleibt bei "Neu"
- "Beenden ohne Speichern?" bei leerem Level
- Langsam, manchmal sogar Deadlock
- ggf. auch Autor in LVL Datei packen und Kommentare in Datei erlauben
- Delphi IDE: Form Height ändern sich automatisch, es wird immer größer.
