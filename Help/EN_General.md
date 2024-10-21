# SpaceMission 1.2.3 documentation

Please also read: [What's new in version 1.2.3?](EN_Changelog.md)

## Description
SpaceMission is a classic space game where you fly through a hail of comets,
Having to shoot down UFOs and other spaceships. There are 31 levels as well
Random levels, i.e. levels that are created by the computer by chance.
With the built-in level editor you can also create your own levels
create. Have fun with SpaceMission.

### Looking for good levels:
If you have created good levels and want to release them in the next version,
please send them by email to info@daniel-marschall.de

## Operation/control
### Space Mission
In the menu, select the menu item using the arrow keys. Press the space bar,
to continue. In the game you control the spaceship using the arrow keys. With the
Space bar shoot.

### Level editor
Select a unit type on the right, you can set the lives below.
Comets are indestructible and therefore have no life. Then you place your bet
Place a unit on the field using the left mouse button. Right click
Click on a unit to delete it. When you delete a unit's lives
you have to delete them and reset them again.

## Scores
Don't forget to save your save.
You can save the game once a level has started.
The game saves your score and lives as well as a copy of the level.
Scores and lives refer to the **beginning** of the level. You can
do not save in the middle of a level.

## Source code
The game's source code is public. SpaceMission can be modified by anyone
or be further developed. The prerequisite is the Embarcadero Delphi programming environment.

Source code at www.github.com/danielmarschall/spacemission


## Creation of savegame and level files
Savegame and level files share the same format; a save file is an extended level file.

[Description of the OID on OIDplus](https://hosted.oidplus.com/viathinksoft/?goto=oid%3A1.3.6.1.4.1.37476.2.8.1.1)

     [1.3.6.1.4.1.37476.2.8.1.1]
     Score  ... (only available if file is a score)
     Lives  ... (only available if file is a saved game)
     Level  ... (only available if file is a saved game)
     Mode   ... (only available if file is a saved game; 1=Normal, 2=Random)
     Name   ...
     Author ...
     Width  ... (default 1200; only relevant for level editor)
     Enemy  <Type> <XCoord> <YCoord> <Life>
     Enemy  <Type> <XCoord> <YCoord> <Life>; Comment line at the end of an opponent line
     Enemy  <Type> <XCoord> <YCoord> <Life>
     Enemy  ...
     ; Comment line

Remarks:
- All level files must have the name "Level [Level-Nr].lev" or all save files must be named "[Name].sav".
- The order of the lines is arbitrary. However, the first line must be exactly correct.
- Empty lines are allowed
- The keyword 'Enemy' applies to both enemies and items.
- `<Type>` = enemy type

			* 1=Attacker type 1 (blau)
			* 2=Attacker type 2 (braun)
			* 3=Attacker type 3 (rot)
			* 4=Meteor
			* 5=UFO type 1 (green)
			* 6=UFO type 2 (orange)
			* 7=Boss
			* 8=Medikit

- `<XCoord>` = Enemy X coordinate (must be divisible by 48 if level is to be edited with level editor)
- `<YCoord>` = Enemy Y coordinate (must be divisible by 32 if level is to be edited with level editor)
- `<Life>` = enemy life (no relevance for comets and items)

##Cheat

Please note that using cheats can spoil your fun!

If you still want to use cheats:

- Cheat for Infinite Lives: Country singer who released "Man in Black" in 1971.

## License Terms

Licensed under the terms of the Apache 2.0 License,
i.e. sharing is expressly desired!

## Author

Homepage: www.daniel-marschall.de
Email: info@daniel-marschall.de