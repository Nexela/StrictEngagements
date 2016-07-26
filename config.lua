--Config File
--Changeing these settings will not affect an existing game unless you run /c remote.call("ntc", "reset")

--Radius of tiles from spawn location to ignore building restrictions. Gives you a little bit of room in case biters move in fast.
SPAWNDISTANCE = 20 --default: 400

--Radius of tiles from enemy where stuff can't be built
BUILDDISTANCE = 200  --default:100

--Limit mode for building restrictions
--Available options are: off, easy, medium, hard
--1 = off - Turns off building restrictions completly
--2 = easy - Only limits building of turret type entites when in range of enemies
--3 = medium - Can only build cars/tanks when in the range of an enemy
--4 = hard -  No Building of ANY entity when in the range of an enemy, this includes cars, hope you can run FAST!
MODE = 3 --default:3


--Will pull 1 coal out of thin air and put it in your car when crafted if there are enemies around. TODO NOT IMPLEMENTED YET
QUICKGETAWAY = false --default:false

--Turret Cooldown, number of seconds before a placed turret will become active  set to 0 to disable cooldown. TODO Not implemented yet.
COOLDOWN = 5 --default:5


--Turn on detailed debugging
--0 = off
--1 = on - only prints to logfile
--2 = on - prints to logfile and player console
DEBUG = 2--default:0
