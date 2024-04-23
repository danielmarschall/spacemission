
# SpaceMission TODO

## Geplant für 1.2.1

- Registry individual Speed Setting

## Geplant für 1.3

- Neue Einheit: Ufo, das im Kreis fliegt und nicht weggeht
- Bei Pause => Entweder alles grau werden lassen, oder vielleicht ganz groß Pause in die Bildschirmmitte schreiben
- Auf Englisch übersetzen
- SplashScreens: als BMP

## Kleinigkeiten

- Es wäre schön, wenn die größe der Spezialhintergründe (Planeten) abhängig von wäre, wie weit entfernt sie ist (Layer 1,2,3)
- wenn man getroffen ist, sollte man blinken, sodass man sieht, ab wann man wieder verwundbar ist
- Improve Sound effects
- Hintergrund besser und Abwechslungsreicher
- Levels besser
- Schrift rechts (Boss: X) soll rechtsbündig sein
- Punkte: Integer-Höchstwert erkennen und dann nicht mehr weiterzählen!
- lev: anzeige - welche datei offen ist!
- punktegebung optimieren

## Ideen

- Neues Item: 10 Sekunden unverwundbarkeit item
- Neues Item: Geld Geschenk item
- Boss schwieriger machen: Er soll auch nach links und rechts gehen?
- Spiellogik: Wenn man gegen einen gegner fliegt, soll er schaden haben!
- Cooldown für Laser? Limitierung der Schüsse (Kanone wird heiß).
- Highscore Liste
- "Throwback" nach einem hit. Nach Treffer, zurückgeschleudert werden
- Anderer Soundeffekt, wenn man selbst getroffen ist
- Leveleditor: "unsaubere" levels akzeptieren! komet mit 1+ leben, einheiten, die nicht auf der linie sind.
- Netzwerkspiel?
- Leveleditor: Ober - / Unterfelder? (was meinte ich damit?)
- Leveleditor: Höchstens 9999 enemies?
- Leveleditor "rückgängig" funktion
- Cheat for next Level ect. (Johnny Crash?)
- Verschiedene Dinge bei schnelligkeit anders?! z.B. Boss-Explore, Schießende  Einheiten (Tamas)
- Tama 1 must damage PL. Sprite!
- Tama 2 must damage EN. Sprite!
- Tama 1 und Tama 2 könnten sich gegenseitig kaputt machen?
- Speicherung: Umbenennen - Button?

## Repro, Unklar, Fragen

- Was ist wenn man mission erfolgreich hatte und dann doch stirbt?
- Que: Gibt es eine neuere Version des Shoot-Samples (nicht mehr vorhanden in aktueller DelphiX)
- Leveleditor performance oder deadlock probleme? bei vielen einheiten wird das sehr langsam? algo verbessern?
- Leveleditor Probleme mit Schiebebildchen...  (was meinte ich damit?)
- Leveleditor Wenn Level gelöscht, dass gerade geladen ist, dann LevChanged = true!
- Leveleditor Boss überschneidet Einheiten ?
- Bei Musik am Anfang bei nicht Focus Anfangsquäker?
- Zeitverschiebung: Texpl dauert länger als Tboss.kill;
- Cheat1 (unverwundbarkeit) mit Kollisionsgeräusch?
- Wenn 0 Levels => Procedur in MainMenu verbessern!
- Wenn Kollision von PlayerSprite vorrüber ist, muss der KollisionsTimer sofort wieder auf Null gehen!
- Wenn keine Soundkarte dann auch kein Sound!
- Spielgeschw. & BGSpeed vereinen
- Dec(live) bei attacker1 manchmal kein Ton?
- Sequences (was meinte ich damit?)
- Rnd: Soll Boss-Live auch RND?
- leicht, mittel, schwer: falsche fps bei langsameren grafikkarten?
- lev: überall ok = focus!
- systemmodus auswählen (move rechnungen ausführen?) oder ein rechenlabel mit dem status anzeigen
- SM: Soll bei Verwaltung lieber statt dem ersten satz bei status was anderes hin? Levelart: Normales Level.
     Wenn es bleiben soll, dann den satz verbessern. Das Level ist ein Zufallslevel
