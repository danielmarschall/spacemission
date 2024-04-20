
# SpaceMission TODO

## Geplant f�r 1.2

- GitHub MarkDown Dokumente auch in Spacemission anzeigen, vielleicht in einem TMemo
- Release 1.2 with EV CodeSign

## Geplant f�r 1.3

- Bei jedem Levelaufstieg 1 Leben geben, alternativ 2 Medikits pro Level
- Neue Einheit: Medikit item
- Neue Einheit: Ufo, das im Kreis fliegt und nicht weggeht
- Bei Pause => Entweder alles grau werden lassen, oder vielleicht ganz gro� Pause in die Bildschirmmitte schreiben
- Level-Editor in die SpaceMission.exe rein und �ber Hauptmen� aufrufen?
- Vorbereitung auf Multilingualit�t (all strings in resourcestrings), ggf. sogar schon auf Englisch �bersetzen
- SplashScreens: als BMP

## Kleinigkeiten

- Es w�re sch�n, wenn die gr��e der Spezialhintergr�nde (Planeten) abh�ngig von w�re, wie weit entfernt sie ist (Layer 1,2,3)
- wenn man getroffen ist, sollte man blinken, sodass man sieht, ab wann man wieder verwundbar ist
- Improve Sound effects
- Hintergrund besser und Abwechslungsreicher
- Levels besser
- Schrift rechts (Boss: X) soll rechtsb�ndig sein
- Punkte: Integer-H�chstwert erkennen und dann nicht mehr weiterz�hlen!
- lev: anzeige - welche datei offen ist!
- punktegebung optimieren

## Ideen

- Neue Einheit: 10 Sekunden unverwundbarkeit item
- Neue Einheit: Geld Geschenk item
- Boss schwieriger machen: Er soll auch nach links und rechts gehen?
- Spiellogik: Wenn man gegen einen gegner fliegt, soll er schaden haben!
- Cooldown f�r Laser? Limitierung der Sch�sse (Kanone wird hei�).
- Highscore Liste
- "Throwback" nach einem hit. Nach Treffer, zur�ckgeschleudert werden
- "unsaubere" levels akzeptieren! komet mit 1+ leben, einheiten, die nicht auf der linie sind.
- Netzwerkspiel?
- Leveleditor: Ober - / Unterfelder? (was meinte ich damit?)
- Leveleditor: H�chstens 9999 enemies?
- Leveleditor "r�ckg�ngig" funktion
- Cheat for next Level ect. (Johnny Crash?)
- Verschiedene Dinge bei schnelligkeit anders?! z.B. Boss-Explore, Schie�ende  Einheiten (Tamas)
- Tama 1 must damage PL. Sprite!
- Tama 2 must damage EN. Sprite!
- Tama 1 und Tama 2 m�ssten sich gegenseitig kaputt machen?
- Speicherung: Umbenennen � Button?

## Repro, Unklar, Fragen

- Was ist wenn man mission erfolgreich hatte und dann doch stirbt?
- versioninfo fehlt bei delphi 12?
- Kartengr��e bleibt bei "Neu"
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)
- Tastenspeere bei runter+links+shot
- "Beenden ohne Speichern?" bei leerem Level
- Leveleditor performance oder deadlock probleme?
- Leveleditor Probleme mit Schiebebildchen...  (was meinte ich damit?)
- Leveleditor Wenn Level gel�scht, dass gerade geladen ist, dann LevChanged = true!
- Leveleditor Boss �berschneidet Einheiten ?
- Bei Musik am Anfang bei nicht Focus Anfangsqu�ker?
- Zeitverschiebung: Texpl dauert l�nger als Tboss.kill;
- Cheat1 (unverwundbarkeit) mit Kollisionsger�usch?
- Wenn 0 Levels ? Procedur in MainMenu verbessern!
- Wenn Kollision von PlayerSprite vorr�ber ist, muss der KollisionsTimer sofort wieder auf Null gehen!
- Wenn keine Soundkarte dann auch kein Sound!
- Spielgeschw. & BGSpeed vereinen
- Dec(live) bei attacker1 manchmal kein Ton?
- Sequences (was meinte ich damit?)
- Rnd: Soll Boss-Live auch RND?
- leicht, mittel, schwer: falsche fps bei langsameren karten
- auch mit einer symbolleiste mit ordnersymbol bei lev (oder sm)?
- lev: �berall ok = focus!
- lev: bei vielen einheiten wird das arsch-langsam? algo verbessern? 
- systemmodus ausw�hlen (move rechnungen ausf�hren?) oder ein rechenlabel mit dem status anzeigen
- SM: Soll bei Verwaltung lieber statt dem ersten satz bei status was anderes hin? Levelart: Normales Level.
     Wenn es bleiben soll, dann den satz verbessern. Das Level ist ein  Zufallslevel
