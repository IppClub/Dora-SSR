local Playable = require("Playable").Type
local Node = require("Node").Type

-- 另一套实现`Playable`接口的动画模型系统。
local record Model

	-- 继承自`Playable`。
	embed Playable

	-- 动画模型是否将倒着播放动画。
	reversed: boolean

	-- 当前动画的持续时间模型。
	const duration: number

	-- 动画模型当前是否正在播放。
	const playing: boolean

	-- 动画模型当前是否处于暂停状态。
	const paused: boolean

	-- 检查模型是否有指定的动画。
	-- @param name (string) 要检查的动画的名称。
	-- @return (boolean) 动画是否存在于模型中。
	hasAnimation: function(self: Model, name: string): boolean

	-- 暂停当前正在播放的动画。
	pause: function(self: Model)

	-- 恢复当前暂停的动画，或者开始播放新的动画。
	-- @param name (string) [可选] 要播放的动画的名称。
	-- @param loop (boolean) [可选] 是否循环播放动画（默认为 false）。
	resume: function(
		self: Model,
		name?: string,
		loop?: boolean --[[false]]
	)

	-- 将当前动画重置为初始状态。
	reset: function(self: Model)

	-- 将动画更新到指定的时间，并可选择以反向播放的进度做更新。
	-- @param elapsed (number) 要更新到的时间。
	-- @param reversed (boolean) [可选] 是否反向播放动画（默认为 false）。
	updateTo: function(
		self: Model,
		elapsed: number,
		reversed?: boolean --[[false]]
	)

	-- 获取指定名称的节点。
	-- @param name (string) 要获取的节点的名称。
	-- @return (Node) 具有指定名称的节点。
	getNodeByName: function(self: Model, name: string): Node

	-- 对模型中的每个节点调用指定的函数，并在函数返回 false 时停止。在迭代过程中，节点不能被添加或删除。
	-- @param func (function) 要为每个节点调用的函数。
	-- @return (boolean) 是否为所有节点调用了函数。
	eachNode: function(self: Model, func: function(Node): boolean): boolean
end

-- 用于创建动画模型实例的类。
local record ModelClass
	type Type = Model

	-- 返回一个新的占位用的空的动画实例的方法。
	-- @return (Model) 新的占位用的动画实例。
	dummy: function(self: ModelClass): Model

	-- 从指定的模型文件中获取图片切片文件名。
	-- @param filename (string) 要搜索的模型文件的文件名。
	-- @return (string) 图片切片文件的名称。
	getClipFile: function(self: ModelClass, filename: string): string

	-- 从指定的模型文件中获取外观名称列表。
	-- @param filename (string) 要搜索的模型文件的文件名。
	-- @return ({string}) 在模型文件中找到的外观名称列表。
	getLooks: function(self: ModelClass, filename: string): {string}

	-- 从指定的模型文件中获取动画名称列表。
	-- @param filename (string) 要搜索的模型文件的文件名。
	-- @return ({string}) 在模型文件中找到的动画名称列表。
	getAnimations: function(self: ModelClass, filename: string): {string}

	-- 从指定的模型文件创建动画模型的新实例。
	-- @param filename (string) 要加载的模型文件的文件名。
	-- 可以是带有扩展名的文件名，如："Model/item" 或 "Model/item.model"。
	-- @return (Model) 动画模型的新实例。
	metamethod __call: function(self: ModelClass, filename: string): Model
end

local modelClass: ModelClass
return modelClass
