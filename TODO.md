
# SpaceMission TODO

Geplant f�r 1.2:
- !!! Gro�es Problem: "Levels" Ordner wird in Program Files sein und ist damit unver�nderbar. Aber wo werden die Benutzer ihr Level hinspeichern k�nnen?
			Hier am besten so vorgehen:
			LEV+SAV Auflistungen: Zuerst gucken, ob eine Leveldatei mit der Levelnummer in "MyGames" liegt, und ansonsten bei "ProgramFiles" gucken
			"MyGames" �berschreibt somit "ProgramFiles" in der Logik
			Bei Auflistungen m�ssen "MyGames" und "ProgramFiles" beide ausgelesen und vereint werden
- Leveleditor "Testen" Button, um die Mission gleich zu testen (dieser erstellt am besten eine tempor�re ".sav" datei, die per commandline mit SpaceMission.exe aufgerufen wird)

Kleinigkeiten:
- Es w�re sch�n, wenn die gr��e der Spezialhintergr�nde (Planeten) abh�ngig von w�re, wie weit entfernt sie ist (Layer 1,2,3)
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
- Cooldown f�r Laser?
- Improve Sound effects
- Level-Editor in die SpaceMission.exe rein und �ber Hauptmen� aufrufen?
- "Doku" in Hilfemen� einbinden, ggf. auch den Leveleditor ins Men� machen
- Highscore Liste
- Multilingual (all strings in resourcestrings)
- Was ist wenn man mission erfolgreich hatte und dann doch stirbt?
- Schrift rechts (Boss: X) soll rechtsb�ndig sein

2015 Review:
- (siehe NOT): weitere �nderungen?
- bewegungsunsch�rfe wegen TFT
- "Throwback" nach einem hit
- weniger startmen�eintr�ge wegen windows 10
- versioninfo
- Multilingual
- SplashScreens: als BMP
- Pause : Bildschirm soll grau werden
- Hintergrund besser und Abwechslungsreicher
- Neues DX: FPS-Limiter f�r Sprite-Animationen -- not a bug: liegt an spielgeschwindigkeit
- Boss schwieriger machen
- Neues UFO das im Kreis fliegt
- Full screen bug beheben + Skalierung verbessern
- Medikits, Unverwundbarkeits-Items
- Limitierung der Sch�sse (Kanone wird hei�)
- Bessere Sounds
- Levels besser machen
- InnoSetup: Nicht mehr so viele Verkn�pfungen (wegen Win10)
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)

SPIEL:
- Nach Treffer, zur�ckgeschleudert werden
- Tastenspeere bei runter+links+shot
- Schutzverletzung bei Spielst�nde aufr

LEVELEDITOR:
- Kartengr��e bleibt bei "Neu"
- "Beenden ohne Speichern?" bei leerem Level
- Langsam, manchmal sogar Deadlock
- ggf. auch Autor in LVL Datei packen und Kommentare in Datei erlauben
- Delphi IDE: Form Height �ndern sich automatisch, es wird immer gr��er.
