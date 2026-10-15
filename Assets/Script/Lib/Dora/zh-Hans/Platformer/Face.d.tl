local Object = require("Object").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- 用于定义游戏子弹或其他游戏对象上挂载的可视化对象的类。
local record Face

	-- 继承自`Object`.
	embed Object

	-- 添加一个子组件的定义。
	-- @param face (Face) 要添加的子定义。
	addChild: function(self: Face, face: Face)

	-- 返回可添加到场景树以进行渲染的节点。
	-- @return (Node) 新的由定义创建的场景节点对象。
	toNode: function(self: Face): Node
end

-- 用于创建可视化组件定义对象的类。
-- @usage
-- local Face = require("Face")
-- local faceA = Face("Image/file.png")
-- local faceB = Face(function()
-- 	return Sprite("Image/file.png")
-- end)
-- faceA:toNode():addTo(entry)
-- faceB:toNode():addTo(entry)
local record FaceClass
	type Type = Face

	-- 创建新的可视化组件的定义对象。
	-- @param faceStr (string) 用于创建可视对象的字符串。
	-- 可以是 'Image/file.png' 和 'Image/items.clip|itemA'。
	-- @param point (Vec2) [可选] 可视组件的位置，默认为 `Vec2.zero`。
	-- @param scale (number) [可选] 可视组件的缩放比例，默认为 1.0。
	-- @param angle (number) [可选] 可视组件的角度，默认为 0.0。
	-- @return (Face) 新的可视组件的定义。
	metamethod __call: function(
		self: FaceClass,
		faceStr: string,
		point?: Vec2 --[[Vec2.zero]],
		scale?: number --[[1.0]],
		angle?: number --[[0.0]]
	): Face

	-- 创建新的可视化组件的定义对象。
	-- @param createFunc (function) 动态创建新的游戏场景节点的函数。
	-- @param point (Vec2) [可选] 可视组件的位置，默认为 `Vec2.zero`。
	-- @param scale (number) [可选] 可视组件的缩放比例，默认为 1.0。
	-- @param angle (number) [可选] 可视组件的角度，默认为 0.0。
	-- @return (Face) 新的可视组件的定义。
	metamethod __call: function(
		self: FaceClass,
		createFunc: function(): (Node),
		point?: Vec2 --[[Vec2.zero]],
		scale?: number --[[1.0]],
		angle?: number --[[0.0]]
	): Face
end

local faceClass: FaceClass
return faceClass
