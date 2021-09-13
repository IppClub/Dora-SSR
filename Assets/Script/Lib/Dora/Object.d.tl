local record Object
	userdata
	const id: integer
	const ref: integer
end
local record ObjectClass
	type Type = Object
	const count: integer
	const maxCount: integer
	const luaRefCount: integer
	const maxLuaRefCount: integer
	const callRefCount: integer
	const maxCallRefCount: integer
end
local objectClass: ObjectClass
return objectClass
