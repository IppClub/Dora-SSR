local Object = require("Object").Type
local Array = require("Array").Type
local type Body = require("BodyType")

-- 表示游戏世界中物理感应器对象的类。
local record Sensor

	-- 继承自`Object`。
	embed Object

	-- 感应器当前是否启用。
	enabled: boolean

	-- 感应器的标签编号。
	const tag: integer

	-- 拥有该感应器的物理体对象。
	const owner: Body

	-- 感应器当前是否感应到游戏世界中的任何其它物理体对象。
	const sensed: boolean

	-- 被感应到的物理体对象列表。
	const sensedBodies: Array

	-- 感应器当前是否感应到指定的物理体对象。
	-- @param body (Body) 要检查是否正在被感应的物理体对象。
	-- @return (boolean) 如果感应器正在感应到物理体对象，则返回true，否则返回false。
	contains: function(self: Sensor, body: Body): boolean
end

return Sensor
