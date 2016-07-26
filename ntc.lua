--NoTurretCreep Main functions

function canWeBuildIt(event)
	if global.mode <= 1 then doDebug("mode is off: Exiting script") return end
	local robot = event.robot
	local player = game.players[event.player_index]
	local builtby = robot or player
	if not builtby then doDebug("builtby is not valid ending script for entity") return end
	local entity = event.created_entity

	if global.mode <=2 and entity.type ~= "turret" then
		doDebug("Mode 2 - Only Turrets are restricted! Exiting Script")
	return end

	if global.mode <=3 and table.ismember(entity.type, global.whitelist) then --TODO loop through allowed list, car, capsules, etc
		if global.quickgetaway then end
		doDebug("Mode 3 - Allow building " ..entity.type.. " from whitelist: Exiting Script")
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

	if not spawnzone then
		if nearby then  --If we are not in the spawnzone and enemies are near
			if player then
				player.print("An enemy force is too close to permit building here")  --TODO Localize
				entity.destroy()
				doDebug("Player Built: An enemy force is too close to permit building")
			elseif robot then
				Game.print_force("A robot is trying to build to close to enemies") --TODO localize
				doDebug("Robot Built: An enemy force is to close to permit building")
			else  --Neither player nor robot
				doDebug("neither player nor robot build")
			return end
		else --No Enemies nearby
			doDebug("No Enemies found safe to build")
		end
	else -- In spawnzone
		doDebug("We are in the Spawnzone ")
	return end
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
