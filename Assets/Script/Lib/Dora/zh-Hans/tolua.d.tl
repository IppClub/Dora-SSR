local Object = require("Object").Type

-- 提供了用于 C++ 和 Lua 之间进行对象转换和处理的工具类。
local record tolua

	-- 返回一个 Lua 对象的 C++ 对象类型名称。
	-- @param item (any) 要获取类型的 Lua 对象。
	-- @return (string) C++ 对象类型名称。
	type: function(item: any): string

	-- 尝试将 Lua 对象动态转换为特定的 C++ 类型对象。
	-- @param item (any) 要转换的 Lua 对象。
	-- @param name (string) 要转换为的 C++ 类型的名称。
	-- @return (T|nil) 转换后的对象，如果转换失败则返回 `nil`。
	cast: function<T>(item: any, name: string): T | nil

	-- 获取给定类名的类对象。
	-- @param className (string) 要获取的类对象的名称。
	-- @return (table|nil) 获取的类对象，如果类不存在则返回 `nil`。
	class: function(className: string): table | nil

	-- 为一个C++对象设置关联表。关联表是一个被 Lua userdata 引用的表，可以为该 userdata 对象提供用户自定义的字段。
	-- @param obj (Object) 要设置关联表的C++对象。
	-- @param data (table) 用作关联表的表。
	setpeer: function(obj: Object, data: table)

	-- 获取一个C++对象上设置的关联表。关联表是一个被 Lua userdata 引用的表，可以为该 userdata 对象提供用户自定义的字段。
	-- @param obj (Object) 要获取关联表的C++对象。
	getpeer: function(obj: Object): table
end

local tolua_: tolua
return tolua_
