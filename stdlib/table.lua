--- Table module
-- @module table

--- Given a mapping function, creates a transformed copy of the table
--- by calling the function for each element in the table, and using
--- the result as the new value for the key. Passes the index as second argument to the function.
--- @usage a= { 1, 2, 3, 4, 5}
---table.map(a, function(v) return v * 10 end) --produces: { 10, 20, 30, 40, 50 }
--- @usage a = {1, 2, 3, 4, 5}
---table.map(a, function(v, k, x) return v * k + x end, 100) --produces { 101, 104, 109, 116, 125}
-- @param tbl to be mapped to the transform
-- @param func to transform values
-- @param[opt] ... additional arguments passed to the function
-- @return a new table containing the keys and mapped values
function table.map(tbl, func, ...)
    local newtbl = {}
    for i, v in pairs(tbl) do
        newtbl[i] = func(v, i, ...)
    end
    return newtbl
end

--- Given a filter function, creates a filtered copy of the table
--- by calling the function for each element in the table, and
--- filtering out any key-value pairs for non-true results. Passes the index as second argument to the function.
--- @usage a= { 1, 2, 3, 4, 5}
---table.filter(a, function(v) return v % 2 == 0 end) --produces: { 2, 4 }
--- @usage a = {1, 2, 3, 4, 5}
---table.filter(a, function(v, k, x) return k % 2 == 1 end) --produces: { 1, 3, 5 }
-- @param tbl to be filtered
-- @param func to filter values
-- @param[opt] ... additional arguments passed to the function
-- @return a new table containing the filtered key-value pairs
function table.filter(tbl, func, ...)
    local newtbl = {}
    local insert = #tbl > 0
    for k, v in pairs(tbl) do
        if func(v, k, ...) then
            if insert then table.insert(newtbl, v)
            else newtbl[k] = v end
        end
    end
    return newtbl
end

--- Given a function, apply it to each element in the table. Passes the index as second argument to the function.
-- @param tbl to be iterated
-- @param func to apply to values
-- @param[opt] ... additional arguments passed to the function
-- @return the given table
function table.each(tbl, func, ...)
    for k, v in pairs(tbl) do
        func(v, k, ...)
    end
    return tbl
end

--- Given an array, returns the first element or nil if no element exists
-- @param tbl the array
-- @return the first element
function table.first(tbl)
    return tbl[1]
end

--- Given an array, returns the last element or nil if no elements exist
-- @param tbl the array
-- @return the last element
function table.last(tbl)
    local size = #tbl
    if size == 0 then return nil end
    return tbl[size]
end


--- Merges 2 tables, values from first get overwritten by second
--- @usage function some_func(x, y, args)
--  args = table.merge({option1=false}, args)
--  if opts.option1 == true then return x else return y end
-- end
-- some_func(1,2) --returns 2
-- some_func(1,2,{option1=true}) --returns 1
-- @param tblA first table
-- @param tblB second table
-- @return tblA with merged values from tblB
function table.merge(tblA, tblB)
    if not tblB then
        return tblA
    end
    for k, v in pairs(tblB) do
        tblA[k] = v
    end
    return tblA
end

-- copied from factorio/data/core/luablib/util.lua

--- Creates a deep copy of table, not coyping Factorio objects
-- @param object the table to copy
-- @return a copy of the table
function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif object.__self then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

--- Returns a copy of all of the keys in the table
-- @param tbl the table to copy the keys from
-- @param sorted (optional) whether to sort the keys (slower) or keep the random order from pairs()
-- @param as_string (optional) whether to try and parse the keys as strings, or leave them as their existing type
-- @return an array with a copy of all the keys in the table
function table.keys(tbl,sorted,as_string)
    local keyset = {}
    local n = 0
    if as_string == true then --checking as_string /before/ looping is faster
        for k,_ in pairs(tbl) do n = n+1 ; keyset[n] = tostring(k) end
    else
        for k,_ in pairs(tbl) do n = n+1 ; keyset[n] = k           end
    end
    if sorted == true then
        table.sort(keyset, function(x,y) --sorts tables with mixed index types.
            local tx = type(x) == 'number'
            local ty = type(y) == 'number'
            if tx == ty then
                return x < y and true or false --similar type can be compared
            elseif tx == true then
                return true --only x is a number and goes first
            else
                return false --only y is a number and goes first
            end
        end)
    end
    return keyset
end

--- Removes keys from a table (sets them to nil)
-- @usage local a = {1, 2, 3, 4}
--table.remove_keys(a, {1,3} --returns {nil, 2, nil, 4}
-- @usage local b = {k1 = 1, k2 = 'foo', old_key = 'bar'}
--table.remove_keys(b, {'old_key'}) --returns {k1 = 1, k2 = 'foo'}
-- @param tbl the table to remove the keys from
-- @param keys array with the keys to remove
-- @return tbl without the specified keys
function table.remove_keys(tbl, keys)
    for i=1, #keys do
        tbl[keys[i]] = nil
    end
    return tbl
end

function table.val_to_str ( v )
  if "string" == type( v ) then
    v = string.gsub( v, "\n", "\\n" )
    if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
      return "'" .. v .. "'"
    end
    return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
  else
    return "table" == type( v ) and table.tostring( v ) or
      tostring( v )
  end
end

function table.key_to_str ( k )
  if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
    return k
  else
    return "[" .. table.val_to_str( k ) .. "]"
  end
end

function table.tostring( tbl )
	if type(tbl) ~= "table" then return tostring(tbl) end
  local result, done = {}, {}
  for k, v in ipairs( tbl ) do
    table.insert( result, table.val_to_str( v ) )
    done[ k ] = true
  end
  for k, v in pairs( tbl ) do
    if not done[ k ] then
      table.insert( result,
        table.key_to_str( k ) .. "=" .. table.val_to_str( v ) )
    end
  end
  return "{" .. table.concat( result, "," ) .. "}"
end

function table.ismember(value, tbl)
	if tbl == nil or value == nil then return false end
	if type(tbl) ~= "table" then
		if tostring(value) == tostring (tbl) then
			return true
		else
			return false
		end
	end
	for k, v in ipairs(tbl) do
		if v == value then return true end
	end

end