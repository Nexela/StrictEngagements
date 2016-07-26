--Control File
require("config")
require("ntc")
require("stdlib/area/area")
require("stdlib/game")
require("stdlib/table")


MOD = {
	name = "NoTurretCreep",
	n = "ntc",
	modes = {"off","easy","medium","hard"},
	whitelist = {"car"},
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
		whitelist = MOD.whitelist,
		playerData={},
		turretData={},
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
    globalVarInit() -- Populate main player variables
    playerInit() -- Initialize all players, No players here during on Init of new game.
   	doDebug("OnGameInit: Initial Setup Complete")
   log(MOD.name ..": Finished Initializing")
end


local function OnGameLoad()-- Called when game is loaded. Do not modify global here, use to set metatables

end


local function OnGameChanged(data)--Called whenever Game Version or any mod Version changes, or when any mods are added or removed.
	doDebug("OnGameChanged: Changes Detected")
		if data.mod_changes ~= nil then
		local changes = data.mod_changes[MOD.name]
		if changes ~= nil then -- THIS Mod has changed
			doDebug(MOD.name .."  Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version), true)
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
    doDebug("OnPlayerJoined: ".. player.index ..":".. player.name)
	newPlayerInit(player)

end


local function OnPlayerRespawned(event)
	local player = game.players[event.player_index]
	doDebug("OnPlayerRespawned: " .. player.index ..":" .. player.name)
end

local function OnPlayerLeft(event)
	local player = game.players[event.player_index]
	doDebug("OnPlayerLeft: " .. player.index ..":".. player.name)
end


script.on_event(defines.events.on_player_created, function(event) OnPlayerCreated(event) end)
script.on_event(defines.events.on_player_joined_game, function(event) OnPlayerJoined(event) end)
script.on_event(defines.events.on_player_respawned, function(event) OnPlayerRespawned(event) end)
script.on_event(defines.events.on_player_left_game, function(event) OnPlayerLeft(event) end)


------------------------------------------------------------------------------------------
--[[ENTITY FUNCTIONS]]--
function OnBuiltEntity(event)
	canWeBuildIt(event)
end

script.on_event(defines.events.on_built_entity, function(event) OnBuiltEntity(event) end )   --event = {player_id, created_entity, name, tick}
script.on_event(defines.events.on_robot_built_entity, function(event) OnBuiltEntity(event) end ) --event = {robot, created_entity, name, tick}


------------------------------------------------------------------------------------------
--[[helpers]]--
function doDebug(msg, alert)
	if DEBUG >= 1 or alert then
		_log.log(table.tostring(msg))
		if DEBUG >= 2 or alert then
			Game.print_all(MOD.n .. ":" .. table.tostring(msg))
		end
	end
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
