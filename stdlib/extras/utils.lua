-- utils.lua by binbinhfr, v1.0.10

-- define debug_status to 1 or nil in the control.lua, before statement require("utils")
-- define also debug_file and debug_mod_name

colors = {
	white = {r = 1, g = 1, b = 1},
	black = {r = 0, g = 0, b = 0},
	darkgrey = {r = 0.25, g = 0.25, b = 0.25},
	grey = {r = 0.5, g = 0.5, b = 0.5},
	lightgrey = {r = 0.75, g = 0.75, b = 0.75},

	red = {r = 1, g = 0, b = 0},
	darkred = {r = 0.5, g = 0, b = 0},
	lightred = {r = 1, g = 0.5, b = 0.5},
	green = {r = 0, g = 1, b = 0},
	darkgreen = {r = 0, g = 0.5, b = 0},
	lightgreen = {r = 0.5, g = 1, b = 0.5},
	blue = {r = 0, g = 0, b = 1},
	darkblue = {r = 0, g = 0, b = 0.5},
	lightblue = {r = 0.5, g = 0.5, b = 1},

	orange = {r = 1, g = 0.55, b = 0.1},
	yellow = {r = 1, g = 1, b = 0},
	pink = {r = 1, g = 0, b = 1},
	purple = {r = 0.6, g = 0.1, b = 0.6},
	brown = {r = 0.6, g = 0.4, b = 0.1},
}

anticolors = {
	white = colors.black,
	black = colors.white,
	darkgrey = colors.white,
	grey = colors.black,
	lightgrey = colors.black,

	red = colors.white,
	darkred = colors.white,
	lightred = colors.black,
	green = colors.black,
	darkgreen = colors.white,
	lightgreen = colors.black,
	blue = colors.white,
	darkblue = colors.white,
	lightblue = colors.black,

	orange = colors.black,
	yellow = colors.black,
	pink = colors.white,
	purple = colors.white,
	brown = colors.white,
}

lightcolors = {
	white = colors.lightgrey,
	grey = colors.darkgrey,
	lightgrey = colors.grey,

	red = colors.lightred,
	green = colors.lightgreen,
	blue = colors.lightblue,
	yellow = colors.orange,
	pink = colors.purple,
}

local author_name1 = "Nexela"
local author_name2 = "binbin"


--------------------------------------------------------------------------------------
--TODO Set goal for force
function SetGoalForAllPlayers( goalText )
	for playerIndex = 1, #game.players do
		if game.players[playerIndex] ~= nil then
			game.players[playerIndex].set_goal_description(goalText)
		end
	end
end

function PrettyNumber( number )
	if number < 1000 then
		return string.format("%i", number)
	elseif number < 1000000 then
		return string.format("%.1fk", (number/1000))
	else
		return string.format("%.1fm", (number/1000000))
	end
end

function GetNearest( objects, point )
	if #objects == 0 then
		return nil
	end

	local maxDist = math.huge
	local nearest = objects[1]
	for _, obj in ipairs(objects) do
		local dist = DistanceSqr(point, obj.position)
		if dist < maxDist then
			maxDist = dist
			nearest = obj
		end
	end

	return nearest
end

function nearest_players( params )
    local origin = params.origin
    local max_distance = params.max_distance or 2
    local list = {}

    for playerIndex = 1, #game.players do
        local player = game.players[playerIndex]
        local distance = util.distance(player.position, origin)
        if distance <= max_distance then
            table.insert(list, player)
        end
    end

    return list
end

function doLog(msg, printplayers)
    if not printplayers then printplayers = false end
    if type(msg) ~= "string" then msg = serpent.dump(msg, {name="var", comment=false, sparse=false, sortkeys=true}) end
	LOGGER.info.log(msg)
	if MOD.debug then LOGGER.debugger.log(msg) end
	if printplayers and game then Game.print_all(msg) end
end

function doDebug(msg, debuganyway)
	if not debuganyway then debuganyway = false end
	if MOD.debug or debuganyway then
	--if type(msg) ~= "string" then msg = serpent.dump(msg, {name="var", comment=false, sparse=false, sortkeys=true}) end
	if type(msg) ~= "string" then msg = "Table Block \n" .. serpent.block(msg, {name="global"}) end
		LOGGER.debugger.log(msg)
	if game then Game.print_all(msg) end
	end
end

function toString(...)
	local s = ""
	
	for i, v in ipairs({...}) do
		s = s .. tostring(v)
	end
	return s
end


--[[
function doLog(msg, option)
if MOD.log or option=true then end
if MOD.debug or option=true then end
if
end
--]]

--[[
function debug_active(...)
	-- can be called everywhere, except in on_load where game is not existing
	local s = ""
	
	for i, v in ipairs({...}) do
		s = s .. tostring(v)
	end

	if s == "RAZ" then
		game.remove_path(debug_file)
		return
	elseif s == "CLEAR" then
		for _, player in pairs(game.players) do
			if player.connected then player.clear_console() end
		end
		return
	end

	s = debug_mod_name .. "(" .. game.tick .. "): " .. s
	game.write_file( debug_file, s .. "\n", true )
	
	for _, player in pairs(game.players) do
		if player.connected then player.print(s) end
	end
end

if debug_status == 1 then debug_print = debug_active else debug_print = function() end end

--------------------------------------------------------------------------------------
function square_area( origin, radius )
	return {
		{x=origin.x - radius, y=origin.y - radius},
		{x=origin.x + radius, y=origin.y + radius}
	}
end

--------------------------------------------------------------------------------------
function distance( pos1, pos2 )
	local dx = pos2.x - pos1.x
	local dy = pos2.y - pos1.y
	return( math.sqrt(dx*dx+dy*dy) )
end

--------------------------------------------------------------------------------------
function distance_square( pos1, pos2 )
	return( max(math.abs(pos2.x - pos1.x),math.abs(pos2.y - pos1.y)) )
end

--------------------------------------------------------------------------------------
function pos_offset( pos, offset )
	return { x=pos.x + offset.x, y=pos.y + offset.y }
end

--------------------------------------------------------------------------------------
function min( val1, val2 )
	if val1 < val2 then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function max( val1, val2 )
	if val1 > val2 then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function iif( cond, val1, val2 )
	if cond then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function add_list(list, obj)
	-- to avoid duplicates...
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			return(false)
		end
	end
	table.insert(list,obj)
	return(true)
end

--------------------------------------------------------------------------------------
function del_list(list, obj)
	for i, obj2 in pairs(list) do
		if obj2 == obj then
			table.remove( list, i )
			return(true)
		end
	end
	return(false)
end

--------------------------------------------------------------------------------------
function in_list(list, obj)
	for k, obj2 in pairs(list) do
		if obj2 == obj then
			return(k)
		end
	end
	return(nil)
end

------------------------------------------------------------------------------------
function is_dev(player)
	return( player.name == author_name1 or player.name == author_name2 )
end

--------------------------------------------------------------------------------------
function dupli_proto( type, name1, name2, adaptMiningResult )
	if data.raw[type][name1] then 
		local proto = table.deepcopy(data.raw[type][name1])
		proto.name = name2
		if adaptMiningResult then
			if proto.minable and proto.minable.result then proto.minable.result = name2	end
		end
		if proto.place_result then proto.place_result = name2 end
		if proto.result then proto.result = name2 end
		return(proto)
	else
		error("prototype unknown " .. name1 )
		return(nil)
	end
end

--------------------------------------------------------------------------------------
function extract_monolith(filename, x, y, w, h)
	return {
		type = "monolith",

		top_monolith_border = 0,
		right_monolith_border = 0,
		bottom_monolith_border = 0,
		left_monolith_border = 0,

		monolith_image = {
			filename = filename,
			priority = "extra-high-no-scale",
			width = w,
			height = h,
			x = x,
			y = y,
		},
	}
end
--]]
