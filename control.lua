--Control File
--luacheck: globals global game script defines MOD Logger log
--luacheck: globals LOGLEVEL
MOD = {
	name = "StrictEngagements",
	n = "se",
	modes = {"off","easy","medium","hard"},
	logfile = {},
}

require("config")
require("util")
require("stdlib/extras/utils")
require("stdlib/area/area")
require("stdlib/game")
require("stdlib/string")
require("stdlib/surface")
require("stdlib/table")
local ntc = require("noturretcreep")
local tcd = require("turretcooldown")
Logger = require("stdlib/log/logger")

MOD.logfile = Logger.new(MOD.name, "info", true, {log_ticks = true})



------------------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]--
local function globalVarInit()
	global = {
		loglevel=LOGLEVEL or 0
	}
end

local function newPlayerInit(player, reset)	-- initialize or update per player globals of the mod
	if global.playerData == nil then global.playerData = {} end
	if reset == true or global.playerData[player.index] == nil then
		global.playerData[player.index] = {
			name = player.name,
		}
		doDebug("newPlayerInit: " .. player.index ..":".. player.name)
	end
end

local function playerInit(reset)
 if reset or not global.playerData then global.playerData = {} end
	for _, player in pairs(game.players) do
		newPlayerInit(player, reset)
		doDebug("playerInit: New Player Added")
	end
end

local function OnGameInit() --Called when mod is first added to a new game
    doDebug("OnGameInit: Initial Setup Started")
    globalVarInit() -- clear global and initialize
    playerInit() -- Initialize all players, No players here during on Init of new game.
    ntc.init()
    tcd.init()
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
local function OnBuiltEntity(event)
	ntc.OnBuiltEntity(event)
end

function OnRobotBuiltEntity(event)
	local entity = event.entity
	local isTurret = table.ismember(entity.name, global.turrets) or table.ismember(entity.type, global.turrets)
	if global.cooldown > 0 and isTurret then
		--turretCoolDown(event.entity, event.robot, true)
		--doDebug("A Robot built from turretlist")
	end -- turretCoolDown
end

local function OnPutItem(event)
	--doDebug("On Put Item Event")

end

script.on_event(defines.events.on_built_entity, function(event) OnBuiltEntity(event) end )   --event = {player_id, created_entity, name, tick}
--script.on_event(defines.events.on_robot_built_entity, function(event) OnRobotBuiltEntity(event) end ) --event = {robot, created_entity, name, tick}
--script.on_event(defines.events.on_put_item, function(event) OnPutItem(event) end)


------------------------------------------------------------------------------------------
--[[TICK FUNCTIONS]]--
function OnTick(event)
	--raiseEvents(event)
	if event.tick % 10 == 0 then

	end -- Every 10 ticks...
end
--script.on_event(defines.events.on_tick, OnTick)
script.on_init(OnGameInit)
script.on_load(OnPlayerCreated)
script.on_configuration_changed(OnGameChanged)

------------------------------------------------------------------------------------------
--[[HELPERS]]--


------------------------------------------------------------------------------------------
--[[REMOTE INTERFACES]]--
local interface = {}

function interface.printGlob(name)
	if name then
        doDebug(global[name], true)
        MOD.logfile.log(serpent.block(global[name]))
    else
        doDebug(global, true)
        MOD.logfile.log(serpent.block(global))
    end
end


function interface.mode(mode)
	global.mode=ntc.getOrsetMode(mode)
end

function interface.loglevel(lvl)
	global.loglevel=lvl
end


function interface.settings(...)
	if arg == nil then game.player.print("NO ARGUMENTS") end
	--changeSettings()
end


function interface.reset()
	initGlobal()
end

remote.add_interface(MOD.n, interface)
