# Changelog

SpaceMission 1.2.3:
- BUGFIX: Bei der englischsprachigen Version wurden viele Texte nicht angezeigt. Korrigiert.

SpaceMission 1.2.2:
- BUGFIX: Items können nun auch eingesammelt werden, wenn man einen infinite lives Cheat aktiviert hat
- BUGFIX: Fehlerkorrektur bei der Anzeige der restlichen Einheiten bei Missionsende
- Übersetzung des Spiels von Deutsch nach Englisch.

SpaceMission 1.2.1:
- Neue Einheit: Medikit Item
- Zufallslevel:
	- Alle 250 Einheiten erhält man ein Medikit
	- Ab Level 25 steigt die Anzahl an auftretenden stärkeren Gegnertypen
- BUGFIX: Nach dem der Boss besiegt wurde, war die angezeigte Gegner-Anzeige eins zu wenig oder ist verschwunden
- BUGFIX: Leveleditor Speicherndialog Frage "Level ersetzen?" Abfrage kommt nun wieder, wenn man ein Selbsterstelltes Level überschreiben möchte
- BUGFIX: Die Geschwindigkeitseinstellung im Menü wurde falsch angezeigt, wenn das Spiel gestartet wurde
- BUGFIX: Zufallslevel: Manche Einheiten sind nicht aufgetaucht, da sie zu weit unten generiert wurden. Korrigiert.
- Mit einer Registry-Änderung kann die Geschwindigkeit nun beliebig eingestellt werden. Registry Schlüssel "Computer\HKEY_CURRENT_USER\Software\ViaThinkSoft\SpaceMission\Settings", Schalter "GameSpeed". Standardwerte: Leicht 10, Mittel 16, Schwer 22, Meister 33.

SpaceMission 1.2:
- Inhaltliche Änderungen am Spiel:
	- Boss besiegen gibt nun 10.000 Punkte anstelle 1.000
	- "Neu starten" Menüpunkt startet nun das Level neu mit den bei Levelstart vorhandenen Punkten und Leben, anstelle von ganz vorne neu zu beginnen
	- Anzeige Restliche Einheiten ist nun Einzeige Einheiten gesamt, d.h. auch die, die auf dem Bildschirm sind (außer Boss)
	- Man kann nun nicht mehr "Game over" gehen. Das Level startet neu, wenn man gestorben ist.
	- Aus technischen Gründen ist es nicht mehr möglich zu speichern, wenn die Anzeige "Level ..., Weiter mit Leertaste" kommt. Man kann jedoch das Level starten und sofort dann mit F4 speichern.
- Zufallslevel:
	- Ab sofort 1 Einheit weniger pro Level
	- Ab sofort Level 1-4 ohne Boss, Level 5-9 mit Boss am Ende, und ab Level 10 Boss in der Mitte vom Level
	- Bei höheren Levels ist die Lebensenergie von Gegnern nun auf 10 gedeckelt
	- Attackierer 2 kommt nun häufiger vor
	- Zufallslevel größer als Level 25 ist nun möglich.
- Änderungen am Level Editor:
	- "Quelltext" Fenster entfernt
	- Gegner-Typ-Name steht nun in der Statusleiste unten
	- Der Leveleditor hat nun eine "Level testen" Funktion
- Technische Änderungen:
	- Es wird nun DirectMusic anstelle MCI zum Abspielen von Musik verwendet. Der Klang ist besser und es gibt weniger Lags.
	- Fenster sind nun in Bildschirm-Mitte und nicht mehr Desktop-Mitte (das macht einen Unterschied bei Multi-Monitor-Systemen).
	- DPlayX.dll wird nicht länger geladen, sodass Windows 11 keine Warnung zeigt, dass DirectPlay nicht installiert ist
	- Spielstände und eigene Levels werden in den Ordner "Gespeicherte Spiele" gesichert (anstelle in den mittlerweile geschützten Programmdateien-Ordner)
	- Einstellungen werden in die Windows Registry gesichert anstelle in eine INI-Datei
	- Quellcode stark verbessert und "redactored"
- Neue LEV und SAV Dateiformate.
	- LEV und SAV Dateien teilen sich das gleiche Format.
	- Es gibt keinen Zwang mehr, die Gegner nach X-Koordinaten zu sortieren.
	- Jeder Gegner wird in einer einzelnen Zeile dargestellt; das Format ist daher sehr übersichtlich
	- Spielstände beinhalten nun die Original-Leveldateien, sodass das wiederherzustellende Spiel exakt gleich aussieht
	- Eigenschaften "Level-Name" und "Level Autor" hinzugefügt.
- "ESC" Taste pausiert das Spiel und öffnet das Menü
- "Level-Konverter" entfernt. Anstelle lesen das Level-Editor und das Spiel nun alle Formate seit SpaceMission 0.2 ein.
- Bugfix: Pause wurde nicht in Titelzeile geschrieben, wenn das Spiel pausiert wurde
- Bugfix: Wenn man pause gemacht hat und fenster wechselt und wieder zurückwechselt, wurde Pause aufgehoben.
- Bugfix: Zwei Fenster wurden in der Taskleiste angezeigt
- "Vollbild" und "Breitbild" Feature entfernt, da es nie richtig funktioniert hat
- Level Editor kann nun über das Hauptmenü aufgerufen werden

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
