local ContainerItem = require("ContainerItemType")

-- 被Lua虚拟机管理的C++对象的基类。
local record Object

	-- 继承自`ContainerItem`。
	embed ContainerItem

	-- C++对象的ID。
	const id: integer

	-- C++对象的Lua引用ID。
	const ref: integer
end

-- 用于访问C++对象管理相关信息的静态类。
local record ObjectClass
	type Type = Object

	-- 所有现存的C++对象的数量。
	const count: integer

	-- 曾经创建的C++对象的最大数量。
	const maxCount: integer

	-- 所有现存的Lua引用的C++对象的计数。
	const luaRefCount: integer

	-- 曾经创建的Lua引用C++对象的最大数量。
	const maxLuaRefCount: integer

	-- Lua引用的C++函数对象的数量。
	const callRefCount: integer

	-- 曾经创建的C++函数调用引用的最大数量。
	const maxCallRefCount: integer
end

local objectClass: ObjectClass
return objectClass
