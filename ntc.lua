--NoTurretCreep Main functions

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
		local spawnzone = atSpawn(entity.position, builtby)
		local nearby = checkForEnemies(entity.position, builtby)
		if not spawnzone then
			if nearby then  --If we are not in the spawnzone and enemies are near
					noWeCant(entity, player)
					isTurret = false  --since we destroyed the entity there is no cake, or turret in this case
					player.print("An enemy force is too close to permit building here")  --TODO Localize
					doDebug("Player Built: An enemy force is too close to permit building")
			else
				doDebug("No Enemies found safe to build")
				turretCoolDown(entity, player)
			end -- nearby enemies
		end-- not In spawnzone
			doDebug("We are in the Spawnzone ")

	end -- main

	if (not spawnzone or global.mode==4) and isTurret then
		turretCoolDown(entity, player, spawnzone)
	end

end

function quickGetAway()
end

function noWeCant(entity, player)
	if entity.name ~= "entity-ghost" then
		player.insert({name = entity.name, count = 1})
		entity.destroy()
	else
		entity.destroy()
	end
return true end

function turretCoolDown(entity, player, spawnzone) --player can be robot entity
	if global.mode <= 1 then doDebug("mode is off: Exiting script") return end --check needed for robots.
end

function atSpawn(entpos, builtby)
	local spawn = builtby.force.get_spawn_position(builtby.surface)
	if Area.inside(Position.expand_to_area(spawn, SPAWNDISTANCE), entpos) then
		--doDebug("We are inside the spawn zone")
	return true end
return false end

function checkForEnemies(entpos, builtby)
      return builtby.surface.find_nearest_enemy {position=entpos, max_distance=BUILDDISTANCE, force=builtby.force}
end


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
