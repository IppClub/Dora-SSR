local type Vec2 = require("Vec2Type")

-- 用于处理鼠标输入的单例类接口。
local record Mouse
	userdata

	-- 鼠标在可视窗口中的位置。
	-- 可以通过使用 `Mouse.position * App.devicePixelRatio` 来获取游戏世界中的坐标。
	-- 然后再使用 `node:convertToNodeSpace()` 来将世界坐标转换为节点的本地坐标。
	-- @usage
	-- local worldPos = Mouse.position * App.devicePixelRatio
	-- local nodePos = node:convertToNodeSpace(worldPos)
	const position: Vec2

	-- 鼠标左键是否正在被按下。
	const leftButtonPressed: boolean

	-- 鼠标右键是否正在被按下。
	const rightButtonPressed: boolean

	-- 鼠标中键是否正在被按下。
	const middleButtonPressed: boolean

	-- 鼠标滚轮的滚动值。
	const wheel: Vec2
end

local mouse: Mouse
return mouse
