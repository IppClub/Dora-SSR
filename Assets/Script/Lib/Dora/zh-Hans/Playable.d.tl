local Node = require("Node").Type
local Vec2 = require("Vec2").Type

-- 用于动画模型系统的接口类。
local record Playable

	-- 继承自`Node`。
	embed Node

	-- 动画模型的外观。
	look: string

	-- 动画模型的播放速度。
	speed: number

	-- 动画模型恢复时间，以秒为单位。
	-- 用于从一个动画过渡到另一个动画。
	recovery: number

	-- 动画模型是否水平翻转。
	fliped: boolean

	-- 当前正在播放的动画名称。
	const current: string

	-- 上一次播放完成的动画名称。
	const lastCompleted: string

	-- 获取模型上的关键点的坐标。
	-- 在 Model 动画系统中，关键点是模型上设置的特定点。在 DragonBone 中，关键点是骨骼的位置。在 Spine2D 中，关键点是顶点附件的位置。
	-- @param name (string) 要获取模型上的关键点的名称。
	-- @return (Vec2) 以二维向量形式返回的关键点的坐标。
	getKey: function(self: Playable, name: string): Vec2

	-- 播放模型包含的动画。
	-- @param name (string) 要播放的动画的名称。
	-- @param loop (boolean) [可选] 是否循环播放动画（默认为 false）。
	-- @return (number) 动画的持续时间，以秒为单位。
	play: function(
		self: Playable,
		name: string,
		loop?: boolean --[[false]]
	): number

	-- 停止当前正在播放的动画。
	stop: function(self: Playable)

	-- 将一个子节点添加到动画模型上的插槽。
	-- @param name (string) 要设置的插槽的名称。
	-- @param item (Node) 要在插槽上添加的节点。
	setSlot: function(self: Playable, name: string, item: Node)

	-- 获取添加到动画模型插槽上的子节点。
	-- @param name (string) 要获取的插槽的名称。
	-- @return (Node|nil) 插槽中的节点，如果插槽中没有节点，则返回 nil。
	getSlot: function(self: Playable, name: string): Node | nil

	-- 注册一个回调函数，当动画播放结束时触发。
	-- @param callback (function) 动画播放结束时的回调函数。
	-- 	@param animationName (string) 播放结束的动画的名称。
	-- 	@param target (Playable) 播放该动画的 Playable 实例。
	onAnimationEnd: function(self: Playable, callback: function(animationName: string, target: Playable))
end

-- 展示动画系统的事件定义，包含事件名称和回调函数参数。
local record __SLOT__

	-- 当动画模型播放结束一个动画后触发。
	-- @param animationName (string) 播放结束的动画名称。
	-- @param target (Playable) 播放该动画的动画模型实例。
	["AnimationEnd"]: function(animationName: string, target: Playable)
end

-- 用于创建动画模型对象的类。
local record PlayableClass
	type Type = Playable

	-- 从指定的动画模型文件创建动画模型的新实例。
	-- @param filename (string) 要加载的动画文件的文件名。
	-- 支持 DragonBone、Spine2D 和 Dora Model 文件。
	-- 必须是以下格式之一：
	-- 	"model:" + modelFile
	-- 	"spine:" + spineStr
	-- 	"bone:" + dragonBoneStr
	-- @return (Playable) 新的动画模型实例，如果加载失败，则返回 nil。
	metamethod __call: function(self: PlayableClass, filename: string): Playable | nil
end

local playableClass: PlayableClass
return playableClass
