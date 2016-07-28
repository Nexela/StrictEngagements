--NoTurretCreep Main functions
ntc = {}
tcd = require("turretcooldown")

local isTurret = false

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
	local entity = event.created_entity
	local player = game.players[event.player_index]

	if not player or not entity return end -- No player or Entity no point in continuing.

	isTurret = table.ismember(entity.name, global.turrets) or table.ismember(entity.type, global.turrettypes)
	local isCreeping=ntc.isCreeping(entity, player)

end


function ntc.atSpawn(entity, pos) --entity to check for, position table to check {x=#, y=#}
	local spawn = entity.force.get_spawn_position(entity.surface)
	if Area.inside(Position.expand_to_area(spawn, global.spawnarea), pos) then
		--doDebug("We are inside the spawn zone")
	return true end
return false end

function ntc.nearbyEnemies(entity, pos) --entity to check for, position table to check {x=#, y=#}
      return entity.surface.find_nearest_enemy {position=pos, max_distance=global.builddistance, force=entity.force}
end

--Can we build the entity here
function ntc.isCreeping(entity, builtby, isrobot, isTurret)
	local mode = global.mode

	if mode <= 1 then doDebug("Mode is 1: exiting check for creep") return false end -- Mode is off who cares if we are creeping?

	local isAllowed = table.ismember(entity.name, global.allowed) or table.ismember(entity.type, global.allowed)

	if global.mode == 2 and isTurret then --return false if type is turret and mode is 2
		doDebug("Mode 2 - Only Turrets restricted!")
		if global.quickGetAway then ntc.quickGetAway(entity) end
		tcd.turretCoolDown(entity, player)
	return false
	elseif global.mode == 3 and isAllowed then --return false if we are allowed to build this and mode is 3
		if global.quickgetaway then ntc.quickGetAway() end
		if isTurret then tcd.turretCoolDown(entity, player) end
		doDebug("Mode 3 - Allow building " ..entity.type.. " from allowed list") --TODO - quick getaway - autofill car with coal, config, autofill mod check.
	return false
	else
		local spawnzone = ntc.atSpawn(player, entity.position)
		local nearby = ntc.nearbyEnemies(player, entity.position)

		if spawnzone then --return false if we inside the spawnzone
			doDebug("Mode ".. mode .. " - Inside Spawnzone, building allowed")
			return false
		end

		if nearby then
			doDebug("Mode " .. mode .. " - Enemies nearby, NO building allowed")
			return true
		end --If we are not in the spawnzone and enemies are near make magic happen
	doDebug("Mode " .. mode .. " - Free to build")
	return false end -- main
return false end

function ntc.weAreCreeping(entity,player)
	if entity.name ~= "entity-ghost" then
		player.insert({name = entity.name, count = 1})
		entity.destroy()
	else
		entity.destroy()
	end
	isTurret = false

	player.print("An enemy force is too close to permit building here")  --TODO Localize
	doDebug("An enemy force is too close to permit building here")
	else
		doDebug("No Enemies found safe to build")
	end -- nearby enemies
end

function ntc.quickGetAway(entity, player)
doDebug("QUICKGETAWAY")
end



--[[
	local player = game.players[event.player_index]
	local entity = event.created_entity
	if not player or not entity then return end --We have a booboo Exit
	local isTurret = table.ismember(entity.type, global.turrettypes)
	local isWhitelist = table.ismemeber(entity.type, global.whitelist)
	local mode=global.mode
	local spawn = false
	local nearby = false
	local stopBuild = false

	if global.mode >=2 then
		stopBuild=true

		if mode = 2 or mode = 3 and (isTurret or isWhitelist) then   --Mode is 2 lets start
			stopBuild=false
			doDebug("Mode 2: Building is not turret or whitelist")
		end

		if mode = 3 and isWhitelist then
			stopBuild=false
			DoDebug("Mode 3: Building is not Whitelist")
		end
		--Stop Build is true

	else
		stopBuild=false
		doDebug("Mode 1: Allow Building")
	end -- global.mode >=2


	end
end



		--isTurret = table.ismember(entity.type, global.turrettypes)
 		spawn = atSpawn(entity.position, player)
		nearby = checkForEnemies(entity.position, player)
	else
		doDebug("Mode is 1: Only limit Turrets")
	end
		--if isTurret and nearby and not spawn then

	if global.mode >=3 and global.mode < 4 then
	end -- Mode 3+

		if global.mode >=4 then
		end -- Mode 4+
	else
		doDebug("Mode is 1: Don't limit building")
	end -- End we have mode





	if global.cooldown > 0 and isTurret then
		turretCoolDown(entity, player)
	end -- turretCoolDown

end


--[[
function canWeBuildIt(event)
	if global.mode <= 1 then doDebug("mode is off: Exiting script") return end

	local player = game.players[event.player_index]
	if not player then doDebug("player is not valid ending script for entity") return end

	local entity = event.created_entity
	local isTurret = table.ismember(entity.type, global.turrettypes)
	local isWhitelist = table.ismember(entity.type, global.whitelist)
	if global.mode <=2 and isTurret then --TODO Turrettypelist
		doDebug("Mode 2 - Only Turrets are restricted!")

	elseif global.mode <=3 and isWhitelist then --TODO loop through allowed list, car, capsules, etc
		if global.quickgetaway then quickGetAway() end
		doDebug("Mode 3 - Allow building " ..entity.type.. " from whitelist")-- Allow building cars for quick getaways --TODO - quick getaway - autofill car with coal, config, autofill mod check.

	else
		local spawnzone = atSpawn(entity.position, player)
		local nearby = checkForEnemies(entity.position, player)
		if not spawnzone then
			if nearby then  --If we are not in the spawnzone and enemies are near
				if entity.name ~= "entity-ghost" then
					player.insert({name = entity.name, count = 1})
					entity.destroy()
				else
					entity.destroy()
				end
					isTurret = false  --since we destroyed the entity there is no cake, or turret in this case
					player.print("An enemy force is too close to permit building here")  --TODO Localize
					doDebug("Player Built: An enemy force is too close to permit building")
			else
				doDebug("No Enemies found safe to build")
				turretCoolDown(entity, player)
			end -- nearby enemies
		end-- not In spawnzone
			--doDebug("We are in the Spawnzone ")

	end -- main

	if (not spawnzone or global.mode==4) and isTurret then
		turretCoolDown(entity, player, spawnzone)
	end

end
--]]

function quickGetAway()
end

function noWeCant(entity, player)

return true end

function turretCoolDown(entity, player, isRobot) --player can be robot entity
	if global.mode <= 1 then doDebug("mode is off: Exiting turretCoolDown script") return end --check needed for robots.
end
--

function atSpawn(entpos, builtby)
	local spawn = builtby.force.get_spawn_position(builtby.surface)
	if Area.inside(Position.expand_to_area(spawn, SPAWNAREA), entpos) then
		doDebug("We are inside the spawn zone")
	return true end
return false end

function checkForEnemies(entpos, builtby)
      return builtby.surface.find_nearest_enemy {position=entpos, max_distance=global.builddistance, force=builtby.force}
end
--]]
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
