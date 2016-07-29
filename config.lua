--Config File
--Changeing these settings will not affect an existing game unless you run /c remote.call("ntc", "reset")

--Radius of tiles from spawn location to ignore building restrictions. Gives you a little bit of room in case biters move in fast.
SPAWNAREA = 200 --default: 200

--Radius of tiles to enemy where stuff can't be built only checks in loaded chunks
BUILDDISTANCE = 100  --default:100

--Limit mode for building restrictions
--Available options are: off, easy, medium, hard
--1 = off - Turns off building restrictions completly
--2 = easy - Only limits building of turret type entites when in range of enemies
--3 = medium - Can only build cars/tanks when in the range of an enemy
--4 = hard -  No Building of ANY entity when in the range of an enemy, this includes cars, hope you can run FAST!
MODE = 2 --default:2


--Will pull 1 coal out of your inventory and stick it in your car when building cars near enemies.
QUICKGETAWAY = true --default:true
-- Will pull 1 coal out of thin air if you don't have any in your inventory.
QUICKGETAWAYCHEAT = false --default:false
--Temorarily disable autofill mod when building vehichles when using QUICKGETAWAY only works with autofill >= 1.4.2
QUICKGETAWAYNOAUTOFILL = true --default:true


--Turret Cooldown, number of seconds before a placed turret will become active  set to 0 to disable cooldown. TODO Not implemented yet. TODO - Technology to lower the time?
COOLDOWN = 10 --default:10


--Turn on detailed debugging
--0 = off - Not recomended
--1 = on - Prints to log
--2 = on - Prints to log and Player
LOGLEVEL = 0--default:0

-----------------------------------------------------------------------------------------
--Allowed name and types can be built regardless of proximity to enemies as long as mode is not 4.
--needs to be in lua table format. see TURRETS for an example
--Allowed can be either an item type (catergory) or an item name.
--In the event that an items name and type are defined the name will be checked first.
--Do not put turrets in this table use TURRETS for those.
ALLOWED = {"car", "land-mine", "combat-robot"}

--Turret Types. To allow turrets of a certain type or name add them to the following list.
TURRETS = {"electric-turret", "ammo-turret"}


