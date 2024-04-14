# Changelog

SpaceMission 1.2:
- Window is now at Screen center instead of Desktop Center
- Removed "level converter" and instead changed level-loading functions to accept level formats 0.2, 0.3, 0.4, and 1.0
- Fix lag when usic changes. Now using DirectX DirectMusic to play music.
- Bugfix: Pause wurde nicht in Caption geschrieben
- Bugfix: Wenn man pause gemacht hat und fenster wechselt und wieder zurückwechselt, wurde Pause aufgehoben.
- DPlayX.dll is no longer loaded, to avoid that Windows show a warning that DirectPlay is not installed
- Removed "Full Screen" feature, because it never really worked.
- Heavily improved and refactored source code.
- Bugfix: Two windows in task bar
- Spielstände werden in den Ordner "Gespeicherte Spiele" gesichert, so wie von Windows definiert!
- Einstellungen werden in Registry gesichert anstelle in eine INI-Datei
- Level Editor: "Quelltext" Fenster entfernt
- Level Editor: Show Enemy Name in the Status Bar
- Level File Format no longer requires being sorted by X coordinates
- Level File Format no longer requires having meteroids 0 lives. (Lifes will be ignored)
- Boss besiegen gibt nun 10.000 Punkte anstelle 1.000
- Neue LEV und SAV Dateiformate

Version 1.1:
- Bugfixes
- Veröffentlichung als OpenSource

Version 1.0:
- Bugfixes
- Die erste vollständige Version von SpaceMission.
- Ein neuer Leveleditor wurde programmiert.

Version 0.4:
- Bugfixes
- Nun auch mit einem Leveleditor.

Version 0.3:
- Bugfixes

Version 0.2:
- Die erste Beta-Version von SpaceMission.
