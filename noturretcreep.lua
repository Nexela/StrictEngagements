--NoTurretCreep Main functions
--luacheck: ignore MODE SPAWNAREA BUILDDISTANCE QUICKGETAWAY QUICKGETAWAYNOAUTOFILL QUICKGETAWAYCHEAT ALLOWED TURRETS
local ntc = {}
local Area = require ("stdlib/area/area")
local Position = require("stdlib/area/position")

--Init the NTC data
function ntc.init()
  --Init the no turret creep module with config values or default values
    global.mode = ntc.getOrsetMode(MODE)
    global.spawnarea = SPAWNAREA or 200
    global.builddistance = BUILDDISTANCE or 100
    global.quickgetaway = QUICKGETAWAY or true
    global.quickgetawaynoautofill = QUICKGETAWAYNOAUTOFILL or true
    global.quickgetawaycheat = QUICKGETAWAYCHEAT or false
    global.allowed = ALLOWED or {"car"}
    global.turrets = TURRETS or {"electric-turret", "ammo-turret"}
end

-------------------------------------------------------------------------------
--[[Helpers]]--

--TODO: Switch to table.any?
local function checkLists(entity, list)
  --list=global[list]
  if not list or not entity then return false end
  if entity.name == "entity-ghost" then return table.getvalue(entity.ghost_name, list) or table.getvalue(entity.ghost_type, list) or false
  else
    return table.getvalue(entity.name, list) or table.getvalue(entity.type, list) or false
  end
end

--Are we at the spawn area?
local function atSpawn(entity, pos) --entity to check for, position table to check {x=#, y=#}
  local spawn = entity.force.get_spawn_position(entity.surface)
  if Area.inside(Position.expand_to_area(spawn, global.spawnarea), pos) then
    doDebug("We are inside the spawn zone")
    return true
  end
  return false
end

--Find the nearest enemy
local function getNearbyEnemies(entity, pos, distance) --entity to check for, position table to check {x=#, y=#}
  distance = distance or global.builddistance
  return entity.surface.find_nearest_enemy {position=pos, max_distance=distance, force=entity.force}
end

-------------------------------------------------------------------------------
--[[NTC Functions]]--

--Lets get away quickly
function ntc.quickGetAway(entity, player)
  if global.quickgetaway and entity.type == "car" and ntc.nearbyEnemies(entity, entity.position, 200) then

    local pos = Position.offset(entity.position, -1, 0)
    local locstring

		--Temporarily disable autofill if compatible version.
    if global.quickgetawaynoautofill and remote.interfaces["af"] and remote.interfaces.af["setUsage"] then
      doDebug("QuickGetAway: Interface valid temporarily disable autofill")
      global.playerData[player.index].autofilltoggled = remote.call("af", "setUsage", player.name, false)
    end

    local inv=player.get_inventory(defines.inventory.player_main) -- Get the players inventory
    local cnt = inv.remove({name = "coal"})
    local clr = defines.colors.yellow

    if cnt > 0 then
      locstring = {"ntc.from-inv", cnt *-1, "coal"}
    else
      locstring = {"ntc.from-thinair", tostring(cnt - 1), "coal"}
      clr=defines.colors.red
    end

		if cnt < 1 then cnt=1 end
    entity.insert({name="coal", count=cnt})
    _G.flyingText(locstring, clr, pos, entity.surface, 10)
  else
    doDebug("QuickGetaway: Disabled, or not car, or no enemies nearby")
  end
end

--Can we build the entity here
function ntc.isCreeping(entity, builtby, isTurret)
  local mode = global.mode

  if mode <= 1 then doDebug("Mode is 1: exiting check for creep") return false end -- Mode is off who cares if we are creeping?

  --local isAllowed = table.getvalue(entity.name, global.allowed) or table.getvalue(entity.type, global.allowed)
  local isAllowed = checkLists(entity, global.allowed)
  if mode == 2 and not isTurret then --return false if type is not turret and mode is 2
    doDebug("Mode 2 - Only Turrets restricted!")
    ntc.quickGetAway(entity, builtby)
    return false
  elseif mode == 3 and isAllowed then --return false if we are allowed to build this and mode is 3
    ntc.quickGetAway(entity, builtby)
    doDebug("Mode 3 - Allow building " .. entity.name .. " from allowed list") --TODO - quick getaway - autofill car with coal, config, autofill mod check.
    return false
  else
    local spawnzone = atSpawn(builtby, entity.position)
    local nearby = getNearbyEnemies(builtby, entity.position)

    if spawnzone then --return false if we inside the spawnzone
      doDebug("Mode ".. mode .. " - Inside Spawnzone, building allowed")
      return false
    end

    if nearby then --If we are not in the spawnzone and enemies are near make magic happen
      --doDebug("Mode " .. mode .. " - Enemies nearby, NO building allowed")
      return true
    end
    doDebug("Mode " .. mode .. " - safe to build")
    return false
  end -- main
end

function ntc.weAreCreeping(entity,player)
  local pos = Position.offset(entity.position, -1, 0)

  if entity.name ~= "entity-ghost" then -- If the item is not a ghost insert it back to the player.
    player.insert({name = entity.name, count = 1})
  end

  entity.surface.create_entity({name = "ntc-cannot-build", position = pos})
  _G.flyingText({"ntc.to-close"}, defines.colors.red, pos, player.surface)
  entity.destroy()
  --player.print({"ntc.to-close"})
  doDebug("An enemy force is too close to permit building here")
end



function ntc.OnBuiltEntity(event)
  local entity = event.created_entity
  local player = game.players[event.player_index]

  if global.playerData[player.index].autofilltoggled == true then -- Turn autofill back on if we disabled it in quickgetaway.
    global.playerData[player.index].autofilltoggled = remote.call("af", "setUsage", player.name, "true")
  end

  local isTurret = checkLists(entity, global.turrets) or false
  if ntc.isCreeping(entity, player, isTurret) then ntc.weAreCreeping(entity, player) end
  --if isTurret then tcd.turretCoolDown() end
end

------------------------------------------------------------------------------------------
--[[helpers]]--
function ntc.getOrsetMode(mode)
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
      doDebug("Invalid mode passed to getOrsetMode, valid options are, 'off', 'easy', 'medium', 'hard' Current Mode='" .. MOD.modes[mode] .. "' Wanted Mode='".. failed .. "'", true)
      return mode
    end
    doDebug("Setting mode to '" .. MOD.modes[mode] .. "'", true)
    return mode
  end

  return ntc
