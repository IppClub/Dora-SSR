local Object = require("Object").Type
local Vec2 = require("Vec2").Type

-- 记录触摸输入或鼠标点击事件信息的类。
local record Touch

	-- 继承自`Object`。
	embed Object

	-- 该触摸事件是否继续启用。
	enabled: boolean

	-- 如果存在多点触控，则此事件是否为第一个触摸事件。
	const first: boolean

	-- 分配给此触摸事件的唯一标识符。
	const id: integer

	-- 自上一个触摸事件以来的移动量和方向。
	const delta: Vec2

	-- 触摸事件在场景节点本地坐标系中的位置。
	const location: Vec2

	-- 触摸事件在世界坐标系中的位置。
	const worldLocation: Vec2
end

return Touch
