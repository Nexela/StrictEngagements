--NoTurretCreep Main functions
ntc = {}
--tcd = require("turretcooldown")



function ntc.init()
--Init the no turret creep module with config values or default values
	if global then
		global.mode = ntc.getOrsetMode(MODE)
		global.spawnarea = SPAWNAREA or 400
		global.builddistance = BUILDDISTANCE or 100
		global.quickgetaway = QUICKGETAWAY or false
		global.allowed = ALLOWED or {"car"}
		global.turrets = TURRETS or {"electric-turret", "ammo-turret"}
	end
end

function ntc.OnBuiltEntity(event)
	local isTurret = false
	local entity = event.created_entity
	local player = game.players[event.player_index]

	if not player or not entity then return end -- No player or Entity no point in continuing.
	isTurret = table.ismember(entity.name, global.turrets) or table.ismember(entity.type, global.turrets)
	if ntc.isCreeping(entity, player, isTurret) then ntc.weAreCreeping(entity, player) end
	if isTurret then tcd.turretCoolDown() end

end


function ntc.atSpawn(entity, pos) --entity to check for, position table to check {x=#, y=#}
	local spawn = entity.force.get_spawn_position(entity.surface)
	if Area.inside(Position.expand_to_area(spawn, global.spawnarea), pos) then
		--doDebug("We are inside the spawn zone")
	return true end
return false end

function ntc.nearbyEnemies(entity, pos, distance) --entity to check for, position table to check {x=#, y=#}
		distance = distance or global.builddistance
      return entity.surface.find_nearest_enemy {position=pos, max_distance=distance, force=entity.force}
end

--Can we build the entity here
function ntc.isCreeping(entity, builtby, isTurret)
	local mode = global.mode

	if mode <= 1 then doDebug("Mode is 1: exiting check for creep") return false end -- Mode is off who cares if we are creeping?

	local isAllowed = table.ismember(entity.name, global.allowed) or table.ismember(entity.type, global.allowed)
	if mode == 2 and not isTurret  then --return false if type is not turret and mode is 2
		doDebug("------------Mode 2 - Only Turrets restricted!")
		if global.quickGetAway then ntc.quickGetAway(entity, builtby) end
		--tcd.turretCoolDown(entity, builtby)
	return false
	elseif mode == 3 and isAllowed then --return false if we are allowed to build this and mode is 3
		if global.quickgetaway then ntc.quickGetAway(entity, builtby) end
		--if isTurret then tcd.turretCoolDown(entity, player) end
		doDebug("Mode 3 - Allow building " .. entity.name .. " from allowed list") --TODO - quick getaway - autofill car with coal, config, autofill mod check.
	return false
	else
		local spawnzone = ntc.atSpawn(builtby, entity.position)
		local nearby = ntc.nearbyEnemies(builtby, entity.position)

		if spawnzone then --return false if we inside the spawnzone
			doDebug("Mode ".. mode .. " - Inside Spawnzone, building allowed")
			return false
		end

		if nearby then
			--doDebug("Mode " .. mode .. " - Enemies nearby, NO building allowed")
			return true
		end --If we are not in the spawnzone and enemies are near make magic happen
	doDebug("Mode " .. mode .. " - Free to build")
	return false end -- main
return false end

function ntc.weAreCreeping(entity,player)
	local pos = Position.offset(entity.position, -1, 0)
	if entity.name ~= "entity-ghost" then
		player.insert({name = entity.name, count = 1})
		entity.surface.create_entity({name = "ntc-cannot-build", position = pos})
		entity.destroy()
	else
		entity.destroy()
	end

	isTurret = false
	flyingText({"ntc.to-close"}, colors.yellow, pos, player.surface)
	--player.print({"ntc.to-close"})  --TODO Localize
	--doDebug("An enemy force is too close to permit building here")
end

function ntc.quickGetAway(entity, player)
	--doDebug("QUICKGETAWAY")
	local pos = Position.offset(player.position, -1, 0)
	local nearby = ntc.nearbyEnemies(entity, entity.position, 200)
	local name = game.item_prototypes["coal"].localised_name
	local entname = entity.localised_name
	if nearby then
		--if remote.interfaces.af then remote.call("af", "toggleUsage", player.name) end --Autfill usage, needs some work though :)
		local inv=player.get_inventory(defines.inventory.player_main)
		if inv.remove({name = "coal"}) then
			locstring= {"ntc.from-pocket", name, entname}
		else
			loclstring = {"ntc.from-ground", name, entname}
		end
		entity.insert({name="coal", count=1})
		flyingText(locstring, colors.yellow, pos, player.surface)
	else
		doDebug("QuickGetaway: No enemies nearby")
	end
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
		doDebug("Invalid mode passed to getOrsetMode, valid options are, 'off', 'easy', 'medium', 'hard'  Current Mode='" .. MOD.modes[mode] .. "' Wanted Mode='".. failed .. "'", true)
		return mode
	end
	doDebug("Setting mode to '" .. MOD.modes[mode] .. "'", true)
	return mode
end

return ntc
