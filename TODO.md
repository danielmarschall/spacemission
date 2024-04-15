
# SpaceMission TODO

Geplant f�r 1.2:
- !!! Gro�es Problem: "Levels" Ordner wird in Program Files sein und ist damit unver�nderbar. Aber wo werden die Benutzer ihr Level hinspeichern k�nnen?
- Leveleditor "Testen" Button, um die Mission gleich zu testen
- Spielst�nde sollten die Level-Information beinhalten (also TLevelData), sodass man wei�, bei welchem Level man weiterspielen muss
	also am besten eine ".lev" datei speichern anstelle einer ".sav" datei, mit den zusatzinfos "punkte,level,leben,modus"

PROBLEM:
- PROBLEM: gro�e level: da ist ewig lang nix!

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
- Bug: 2 Taskleisteneintr�ge
- Multilingual
- SplashScreens: als BMP
- Intro : Enter anstelle Leertaste
- Pause : Bildschirm soll grau werden
- Hintergrund besser und Abwechslungsreicher
- Neues DX: FPS-Limiter f�r Sprite-Animationen -- not a bug: liegt an spielgeschwindigkeit
- Verschiedene Schwierigkeitsstufen (Geschwindigkeiten)
- Boss schwieriger machen
- Neues UFO das im Kreis fliegt
- Endloses Zufallsspiel
- Full screen bug beheben + Skalierung verbessern
- Medikits, Unverwundbarkeits-Items
- Limitierung der Sch�sse (Kanone wird hei�)
- Bessere Sounds
- Quellcode optimieren, keine Compilerwarnungen mehr
- Levels besser machen
- Ordnerstruktur vereinfachen (nicht f�r alles einen Unterordner)
- Nicht mehr auf die Existenz jeder einzelnen Datei pr�fen
- InnoSetup: Nicht mehr so viele Verkn�pfungen (wegen Win10)
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)

SPIEL:
- Nach Treffer, zur�ckgeschleudert werden
- Vollbildwechsel geht nicht
- Tastenspeere bei runter+links+shot
- Schutzverletzung bei Spielst�nde aufr

LEVELEDITOR:
- Kartengr��e bleibt bei "Neu"
- "Beenden ohne Speichern?" bei leerem Level
- Langsam, manchmal sogar Deadlock
- ggf. auch Autor in LVL Datei packen und Kommentare in Datei erlauben
- Delphi IDE: Form Height �ndern sich automatisch, es wird immer gr��er.
