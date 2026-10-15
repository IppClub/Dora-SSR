local Playable = require("Playable").Type

-- 继承 `Playable` 接口使用 DragonBones 系统实现动画功能的类。
local record DragonBone

	-- 继承自`Playable`。
	embed Playable

	-- 是否启用碰撞检测的功能。
	hitTestEnabled: boolean

	-- 检查一个点坐标是否在动画模型的碰撞检测边界内，并返回该点处的骨骼或插槽名称。
	-- @param x (number) 要检查的点的 x 坐标。
	-- @param y (number) 要检查的点的 y 坐标。
	-- @return (string|nil) 该点处的骨骼或插槽名称，如果没有找到骨骼或插槽则返回 nil。
	containsPoint: function(self: DragonBone, x: number, y: number): string | nil

	-- 检查线段是否与动画模型的碰撞检测边界相交，并返回交点处的骨骼或插槽名称。
	-- @param x1 (number) 线段起点的 x 坐标。
	-- @param y1 (number) 线段起点的 y 坐标。
	-- @param x2 (number) 线段终点的 x 坐标。
	-- @param y2 (number) 线段终点的 y 坐标。
	-- @return (string|nil) 交点处的骨骼或插槽名称，如果没有找到骨骼或插槽则返回 nil。
	intersectsSegment: function(self: DragonBone, x1: number, y1: number, x2: number, y2: number): string | nil
end

-- 用于创建`DragonBone`对象的类。
local record DragonBoneClass
	type Type = DragonBone

	-- 返回`DragonBone`动画模型文件的可用的外观列表。
	-- @param boneStr (string) 要获取外观的`DragonBone`文件名字符串。
	-- @return ({string}) 包含可用外观的字符串列表。
	getLooks: function(self: DragonBoneClass, boneStr: string): {string}

	-- 返回`DragonBone`动画模型文件的可用的动画列表。
	-- @param boneStr (string) 要获取动画的`DragonBone`文件名字符串。
	-- @return ({string}) 包含可用动画的字符串列表。
	getAnimations: function(self: DragonBoneClass, boneStr: string): {string}

	-- 使用指定的骨骼字符串创建`DragonBone`的新实例。
	-- @param boneStr (string) 用于创建新实例的`DragonBone`文件名字符串。
	-- `DragonBone`文件名字符串可以是不带扩展名的文件路径，例如 "DragonBone/item"，或包含所有相关扩展名的完整文件路径，例如："DragonBone/item_ske.json|DragonBone/item_tex.json"。
	-- 并且可以在分号后添加骨架名称。例如 "DragonBone/item;mainArmature" 或 "DragonBone/item_ske.json|DragonBone/item_tex.json;mainArmature"。
	-- @return (DragonBone) 'DragonBone' 的新实例。如果找不到指定的文件，则返回 nil。
	metamethod __call: function(self: DragonBoneClass, boneStr: string): DragonBone | nil

	-- 使用指定的骨骼和图集文件创建`DragonBone`的新实例。
	-- 此函数仅加载模型文件内的第一个骨架。
	-- @param boneFile (string) 要加载的骨骼文件的文件名。
	-- @param atlasFile (string) 要加载的图集文件的文件名。
	-- @return (DragonBone) 带有指定骨骼文件和图集文件的`DragonBone`的新实例。如果找不到指定的文件，则返回 nil。
	metamethod __call: function(self: DragonBoneClass, boneFile: string, atlasFile: string): DragonBone | nil
end

local dragonBoneClass: DragonBoneClass
return dragonBoneClass
