local Object = require("Object").Type

-- The `tolua` record provides utilities for interfacing between C++ and Lua.
local record tolua

	-- Returns the C++ object type of a Lua object.
	-- @param item (any) The Lua object to get the type of.
	-- @return (string) The C++ object type.
	type: function(item: any): string

	-- Attempts to cast a Lua object to a C++ type object.
	-- @param item (any) The Lua object to cast.
	-- @param name (string) The name of the C++ type to cast to.
	-- @return (T|nil) The cast object, or `nil` if the cast fails.
	cast: function<T>(item: any, name: string): T | nil

	-- Gets the class object for a given class name.
	-- @param className (string) The name of the class to get the table for.
	-- @return (table|nil) The class table, or `nil` if the class does not exist.
	class: function(className: string): table | nil

	-- Sets the peer table for an object. A pear table is a table referenced by a Lua userdata providing custom fields for this userdata object.
	-- @param obj (Object) The object to set the peer table for.
	-- @param data (table) The table to use as the peer table.
	setpeer: function(obj: Object, data: table)

	-- Gets the peer table for an object. A pear table is a table referenced by a Lua userdata providing custom fields for this userdata object.
	-- @param obj (Object) The object to get the peer table for.
	-- @return (table) The peer table, or nil if the object has no peer table.
	getpeer: function(obj: Object): table
end

local tolua_: tolua
return tolua_
