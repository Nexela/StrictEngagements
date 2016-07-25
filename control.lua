--Control File
require("config")
require("stdlib/area/area")
require("stdlib/game")
require("stdlib/table")

MOD = {
	name = "NoTurretCreep",
	n = "ntc",
	modes = {"off","easy","medium","hard"},
}

if DEBUG then
	require("stdlib/log/logger")
	_log = Logger.new(MOD.name, "debug", true, {log_ticks = true})
	else
	_log = function() end
end

------------------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]--
function globalVarInit()
	global = {
		mode=getOrsetMode(MODE),
		spawndistance=SPAWNDISTANCE,
		builddistance=BUILDDISTANCE,
		quickgetaway=QUICKGETAWAY,
		playerData={},
	}
end


local function playerInit(reset)
	for _, player in pairs(game.players) do
		newPlayerInit(player, reset)
		doDebug("playerInit: New Player Added")
	end
end


function newPlayerInit(player, reset)	-- initialize or update per player globals of the mod
	if global.playerData == nil then global.playerData = {} end
	if reset == true or global.playerData[player.index] == nil then
		global.playerData[player.index] = {
			name = player.name,
		}
		doDebug("newPlayerInit: " .. player.index ..":".. player.name)
	end
end

local function OnGameInit() --Called when mod is first added to a new game
    doDebug("OnGameInit: Initial Setup Started")
    globalVarInit() -- Populated main player variables
    playerInit() -- Initialize all players but there are no players here???
   	doDebug("OnGameInit: Initial Setup Complete")
   log(MOD.name ..": Finished Initializing")
end


local function OnGameLoad()-- Called when game is loaded. Can cause Desyncs if used incorrectly

end


local function OnGameChanged(data)--Called whenever Game Version or any mod Version changes, or when any mods are added or removed.
	doDebug("OnGameChanged: = Changes Detected")
		if data.mod_changes ~= nil then
		local changes = data.mod_changes[MOD.name]
		if changes ~= nil then -- THIS Mod has changed
			doDebug(MOD.name .."  Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version))
     		--Do Stuff Here if needed
		end
	end
end

script.on_init(OnGameInit)
script.on_load(OnPlayerCreated)
script.on_configuration_changed(OnGameGhanged)

------------------------------------------------------------------------------------------
--[[PLAYER FUNCTIONS]]--
local function OnPlayerCreated(event)--Called Everytime a new player is created
    local player = game.players[event.player_index]
	doDebug("OnPlayerCreated = ".. player.index ..":".. player.name)
	newPlayerInit(player)

end


local function OnPlayerJoined(event)--Called when players join
    local player = game.players[event.player_index]
    doDebug("OnPlayerJoined = ".. player.index ..":".. player.name)
	newPlayerInit(player)

end

local function OnPlayerRespawned(event)
	local player = game.players[event.player_index]
	doDebug("OnPlayerRespawned = " .. player.index ..":" .. player.name)
end

local function OnPlayerLeft(event)
	local player = game.players[event.player_index]
	doDebug("OnPlayerLeft = " .. player.index ..":".. player.name)
end

script.on_event(defines.events.on_player_created, function(event) OnPlayerCreated(event) end)
script.on_event(defines.events.on_player_joined_game, function(event) OnPlayerJoined(event) end)
script.on_event(defines.events.on_player_respawned, function(event) OnPlayerRespawned(event) end)
script.on_event(defines.events.on_player_left_game, function(event) OnPlayerLeft(event) end)

------------------------------------------------------------------------------------------
--[[ENTITY FUNCTIONS]]--
function OnBuiltEntity(event)
	if global.mode <= 1 then doDebug("mode is off, exiting script") return end
	local robot = event.robot
	local player = game.players[event.player_index]
	local builtby = robot or player
	if not builtby then doDebug("builtby is not valid ending script for entity") return end
	local entity = event.created_entity

	if global.mode <=2 and entity.type ~= "turret" then
		doDebug("Mode 2 - Only Turrets are restricted! Exiting Script")
	return end

	if global.mode <=3 and entity.type == "car" then
		if global.quickgetaway then end
		doDebug("Mode 3 - Allow building a car for a quick getaway! Exiting Script")
	return end -- Allow building cars for quick getaways --TODO - quick getaway - autofill car with coal, config, autofill mod check.

	local spawnzone = atSpawn(entity.position, builtby)
	local nearby = checkForEnemies(entity.position, builtby)
	--local spawn=atSpawn(entity.position, player)
	--local nearbyEnemies = checkForEnemies(entity.position, player)

	--[[
	if robot then
		doDebug("Robot is building Entity")
	elseif player then
		doDebug("Player is building Entity")
	else
		doDebug("Entity built but something went wrong, Stopping script for this entity", true)
		return  -- ERROR!, something went wrong here........
	end
	--]]

	if not spawnzone and nearby then
		if player then
			player.print("An enemy force is too close to permit building here")  --TODO Localize
			entity.destroy()
			doDebug("Player Built: An enemy force is too close to permit building")
		elseif robot then
			Game.print_force("A robot is trying to build to close to enemies") --TODO localize
			doDebug("Robot Built: An enemy force is to close to permit building")
		end
		--doDebug("No Enemies found safe to build")
	end
end




function atSpawn(entpos, builtby)
	local spawn = builtby.force.get_spawn_position(builtby.surface)
	if Area.inside(Position.expand_to_area(spawn, SPAWNDISTANCE), entpos) then
		doDebug("We are inside the spawn zone")
	return true end
return false end

function checkForEnemies(entpos, builtby)
      return builtby.surface.find_nearest_enemy {position=entpos, max_distance=BUILDDISTANCE, force=builtby.force}
end

function doDebug(msg, alert)
	if DEBUG or alert then
		_log.log(table.tostring(msg))
		Game.print_all(table.tostring(msg))
	end
end


script.on_event(defines.events.on_built_entity, function(event) OnBuiltEntity(event) end )   --event = {player_id, created_entity, name, tick}
script.on_event(defines.events.on_robot_built_entity, function(event) OnBuiltEntity(event) end ) --event = {robot, created_entity, name, tick}

------------------------------------------------------------------------------------------
--[[helpers]]--
function getOrsetMode(mode)
	if not mode and global.mode then
		doDebug("Current mode is '" .. MOD.modes[global.mode].."'", true)
	return global.mode end
	if type(mode) == "string" then mode=string.lower(mode) end
	if mode == "off" or mode == 1 then mode = 1
	elseif mode == "easy" or mode == 2 then mode = 2
	elseif mode == "medium" or mode == 3 then mode = 3
	elseif mode == "hard" or mode == 4 then mode = 4
	else
		local failed = mode or "nil"
		--if failed==nil then failed="nil" end
		mode=global.mode or 3
		doDebug("Invalid mode passed to getOrsetMode, valid options are, 'off', 'easy', 'medium', 'hard'  Current Mode='" .. MOD.modes[mode] .. "' Wanted Mode='".. failed .. "'", true)
		return mode
	end
	doDebug("Setting mode to '" .. MOD.modes[mode] .. "'", true)
	return mode
end


------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]--

local interface = {}

function interface.printGlob(name)
	if name then
        doDebug(global[name], true)
    else
        doDebug(global, true)
    end
end

function interface.mode(mode)
	global.mode=getOrsetMode(mode)
end

function interface.settings(...)
	if arg == nil then game.player.print("NO ARGUMENTS") end
	--changeSettings()
end

function interface.reset()
	initGlobal()
end

remote.add_interface(MOD.n, interface)
