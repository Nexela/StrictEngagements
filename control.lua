--Control File
--luacheck: globals LOGLEVEL
MOD = {
  name = "StrictEngagements",
  n = "se",
  modes = {"off","easy","medium","hard"},
  logfile = {},
}

require("config")
require("stdlib/extras/utils") --Main STDLIB includes all Top level Globals
local ntc = require("noturretcreep")
--local tcd = require("turretcooldown") -- No point including this yet.
Logger = require("stdlib/log/logger")

MOD.logfile = Logger.new(MOD.name, "info", true, {log_ticks = true})

------------------------------------------------------------------------------------------
--[[HELPER FUNCTIONS]]--
local function globalVarInit()
  global = {
    loglevel=LOGLEVEL or 0
  }
end

local function newPlayerInit(player, reset) -- initialize or update per player globals of the mod
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

------------------------------------------------------------------------------------------
--[[ENTITY FUNCTIONS]]--
local function OnBuiltEntity(event)
  ntc.OnBuiltEntity(event)
end
script.on_event(defines.events.on_built_entity, function(event) OnBuiltEntity(event) end )

------------------------------------------------------------------------------------------
--[[INIT FUNCTIONS]]--
local function OnPlayerCreated(event)--Called Everytime a new player is created
  local player = game.players[event.player_index]
  doDebug("OnPlayerCreated = ".. player.index ..":".. player.name)
  newPlayerInit(player)
end
script.on_event(defines.events.on_player_created, function(event) OnPlayerCreated(event) end)

local function OnGameInit() --Called when mod is first added to a new game
  doDebug("OnGameInit: Initial Setup Started")
  globalVarInit() -- clear global and initialize
  playerInit() -- Initialize all players, No players here during on Init of new game.
  ntc.init()
  --tcd.init()
  doDebug("OnGameInit: Initial Setup Complete")
  log(MOD.name ..": Finished Initializing")
end
script.on_init(OnGameInit)

local function OnGameChanged(data)--Called whenever Game Version or any mod Version changes, or when any mods are added or removed.
  doDebug("OnGameChanged: Changes Detected")
  if data.mod_changes ~= nil then
    local changes = data.mod_changes[MOD.name]
    if changes ~= nil then -- THIS Mod has changed
      doDebug(MOD.name .." Updated from ".. tostring(changes.old_version) .. " to " .. tostring(changes.new_version), true)
      --Do Stuff Here if needed
    end
  end
end
script.on_configuration_changed(OnGameChanged)

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

function interface.reset()
  OnGameInit()
end

remote.add_interface(MOD.n, interface)
