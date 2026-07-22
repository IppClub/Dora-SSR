local type Vec2 = require("Vec2Type")

-- 用于处理鼠标输入的单例类接口。
local record Mouse
	userdata

	-- 鼠标在可视窗口逻辑坐标系中的位置，原点位于左上角。
	-- 在 2D 场景中，应先将其映射到 `View.size`，应用 Camera2D 的逆变换，再调用 `node:convertToNodeSpace()`。
	-- 摄像机缩放需要做除法而不是乘法。对于节点 3D 变换或自定义投影，请改用 `node:onMouseMove()` 并读取 `touch.location`。
	-- @usage
	-- local node = Node()
	-- local camera = Director.currentCamera as Camera2D.Type
	-- local mouse = Mouse.position
	-- local visualSize = App.visualSize
	-- local viewSize = View.size
	-- local viewPos = Vec2(
	-- 	mouse.x * viewSize.width / visualSize.width - viewSize.width / 2,
	-- 	viewSize.height / 2 - mouse.y * viewSize.height / visualSize.height
	-- ) / camera.zoom
	-- local angle = math.rad(camera.rotation)
	-- local worldPos = Vec2(
	-- 	viewPos.x * math.cos(angle) - viewPos.y * math.sin(angle),
	-- 	viewPos.x * math.sin(angle) + viewPos.y * math.cos(angle)
	-- ) + camera.position
	-- local nodePos = node:convertToNodeSpace(worldPos)
	const position: Vec2

	-- 从上一帧开始累计的鼠标移动量。
	const delta: Vec2

	-- 是否启用相对鼠标模式。相对模式会隐藏并捕获鼠标光标。
	relativeMode: boolean

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
