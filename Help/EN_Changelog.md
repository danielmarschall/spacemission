# Changelog

SpaceMission 1.2.3 (2025):
- Internal change of translation tool
- Codesigning

SpaceMission 1.2.3 (2024):
- BUGFIX: A lot of texts were not displayed on English systems.

SpaceMission 1.2.2:
- BUGFIX: Items can now also be collected if you have activated an infinite lives cheat
- BUGFIX: Bug fix when displaying remaining units at mission end
- Translation of the game from German to English.

SpaceMission 1.2.1:
- New unit: Medikit Item
- Random level:
- You get a Medikit every 250 units
- From level 25 onwards, the number of stronger enemy types that appear increases
- BUGFIX: After the boss was defeated, the displayed enemy display was one too few or disappeared
- BUGFIX: Level editor save dialog question "Replace level?" The query now appears again if you want to overwrite a self-created level
- BUGFIX: The speed setting in the menu was displayed incorrectly when starting the game
- BUGFIX: Random level: Some units didn't appear because they were generated too far down. Corrected.
- With a registry change, the speed can now be set as desired. Registry key "Computer\HKEY_CURRENT_USER\Software\ViaThinkSoft\SpaceMission\Settings", switch "GameSpeed". Default stats: Easy 10, Medium 16, Hard 22, Master 33.

Space Mission 1.2:
- Content changes to the game:
- Defeating a boss now gives 10,000 points instead of 1,000
- "Restart" menu item now restarts the level with the points and lives present at the start of the level, instead of starting over from the beginning
- Remaining units display is now showing total units, i.e. including those that are on the screen (except boss)
- You can no longer go “Game Over”. The level restarts when you die.
- For technical reasons it is no longer possible to save when the message "Level ..., continue with spacebar" appears. However, you can start the level and then immediately save it with F4.
- Random level:
- From now on 1 unit less per level
- From now on levels 1-4 without a boss, levels 5-9 with a boss at the end, and from level 10 a boss in the middle of the level
- At higher levels, the health of enemies is now capped at 10
- Attacker 2 now appears more frequently
- Random level greater than level 25 is now possible.
- Changes to the level editor:
- "Source code" window removed
- Enemy type name is now in the status bar at the bottom
- The level editor now has a "test level" function
- Technical changes:
- DirectMusic is now used instead of MCI to play music. The sound is better and there is less lag.
- Windows are now in the middle of the screen and no longer in the middle of the desktop (this makes a difference in multi-monitor systems).
- DPlayX.dll no longer loads, so Windows 11 does not show a warning that DirectPlay is not installed
- Saved games and custom levels are saved to the "Saved Games" folder (instead of the now protected Program Files folder)
- Settings are saved to the Windows registry instead of an INI file
- Source code greatly improved and redacted
- New LEV and SAV file formats.
- LEV and SAV files share the same format.
- There is no longer any need to sort enemies by X coordinates.
- Each enemy is displayed on a single line; The format is therefore very clear
- Savegames now include the original level files, so the game being restored looks exactly the same
- Added "Level Name" and "Level Author" properties.
- "ESC" key pauses the game and opens the menu
- "Level converter" removed. Instead, the level editor and the game now read all formats since SpaceMission 0.2.
- Bugfix: Pause was not written in the title bar when the game was paused
- Bug fix: If you took a break and changed windows and then changed back again, the break was canceled.
- Bugfix: Two windows were displayed in the taskbar
- Removed "Fullscreen" and "Widescreen" features as they never worked properly
- Level Editor can now be accessed from the main menu

Version 1.1:
- Bug fixes
- Publication as OpenSource

Version 1.0:
- Bug fixes
- The first full version of SpaceMission.
- A new level editor has been programmed.

Version 0.4:
- Bug fixes
- Now also with a level editor.

Version 0.3:
- Bug fixes

Version 0.2:
- The first beta version of SpaceMission.
