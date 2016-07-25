--Config File

--Radius of tiles from spawn location to ignore building restrictions. Gives you a little bit of room in case biters move in fast.
SPAWNDISTANCE = 20 --default: 400

--Radius of tiles from enemy where stuff can't be built
BUILDDISTANCE = 100  --default:100

--Limit mode for building restrictions
--Available options are: off, easy, medium, hard
--1 = off - Turns off building restrictions completly
--2 = easy - Only limits building of turret type entites when in range of enemies
--3 = medium - Can only build cars/tanks when in the range of an enemy
--4 = hard -  No Building of ANY entity when in the range of an enemy, this includes cars, hope you can run FAST!
MODE = 3 --default:3


--Will pull 1 coal out of thin air and put it in your car when crafted if there are enemies around. NOT IMPLEMENTED YET
QUICKGETAWAY = false --default:false


--Turn on detailed debugging
DEBUG = true --default:false
