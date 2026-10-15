local ContainerItem = require("ContainerItemType")

-- An class that is a base class for many C++ objects that managed by Lua VM.
local record Object
	embed ContainerItem

	-- The ID of the C++ object.
	const id: integer

	-- The Lua reference ID for this C++ object.
	const ref: integer
end

-- The static class for accessing object class attributes.
local record ObjectClass
	type Type = Object

	-- The number of total existing C++ objects.
	const count: integer

	-- The maximum number of C++ objects that were ever created.
	const maxCount: integer

	-- The number of total existing Lua references to C++ objects.
	const luaRefCount: integer

	-- The maximum number of Lua references that were ever created.
	const maxLuaRefCount: integer

	-- The number of C++ function call objects referenced by Lua.
	const callRefCount: integer

	-- The maximum number of C++ function call references that were ever created.
	const maxCallRefCount: integer
end

local objectClass: ObjectClass
return objectClass
