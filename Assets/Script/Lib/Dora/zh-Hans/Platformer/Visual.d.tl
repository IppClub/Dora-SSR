local Node = require("Node").Type

-- 代表粒子、帧动画或精灵之类的可视效果对象的类。
local record Visual

	-- 继承自`Node`.
	embed Node

	-- 是否正在播放可视效果。
	const playing: boolean

	-- 开始播放可视效果。
	start: function(self: Visual)

	-- 停止播放可视效果。
	stop: function(self: Visual)

	-- 当可视效果播放完毕时，自动将其从游戏场景树中移除。
	-- @return (Visual) 当前的可视效果结点对象，用于方法级连调用。
	autoRemove: function(self: Visual): Visual
end

-- 用于创建可视效果对象的类。
local record VisualClass
	type Type = Visual

	-- 使用指定的名称创建新的可视效果对象。
	-- @param name (string) 新可视效果对象的名称。
	-- 可以是粒子文件、帧动画文件或图像文件。
	-- @return (Visual) 新的可视效果对象。
	metamethod __call: function(self: VisualClass, name: string): Visual
end

local visualClass: VisualClass
return visualClass
