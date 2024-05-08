local Playable = require("Playable").Type

-- 使用 Spine2D 引擎实现的动画模型系统的类。
local record Spine

	-- 继承自`Playable`.
	embed Playable

	-- 是否启用碰撞检测的功能。
	hitTestEnabled: boolean

	-- 设置`Spine`骨骼中骨骼的旋转角度。
	-- @param name (string) 骨骼的名称。
	-- @param rotation (number) 骨骼旋转的角度，以度数为单位。
	-- @return (boolean) 旋转是否成功设置。
	setBoneRotation: function(self: Spine, name: string, rotation: number): boolean

	-- 检查一个点坐标是否在动画模型的碰撞检测边界内，并返回该点处的骨骼或插槽名称。
	-- @param x (number) 要检查的点的 x 坐标。
	-- @param y (number) 要检查的点的 y 坐标。
	-- @return (string|nil) 该点处的骨骼或插槽名称，如果没有找到骨骼或插槽则返回 nil。
	containsPoint: function(self: Spine, x: number, y: number): string | nil

	-- 检查线段是否与动画模型的碰撞检测边界相交，并返回交点处的骨骼或插槽名称。
	-- @param x1 (number) 线段起点的 x 坐标。
	-- @param y1 (number) 线段起点的 y 坐标。
	-- @param x2 (number) 线段终点的 x 坐标。
	-- @param y2 (number) 线段终点的 y 坐标。
	-- @return (string|nil) 交点处的骨骼或插槽名称，如果没有找到骨骼或插槽则返回 nil。
	intersectsSegment: function(self: Spine, x1: number, y1: number, x2: number, y2: number): string | nil
end

-- 用于创建`Spine`动画模型实例的类。
local record SpineClass
	type Type = Spine

	-- 返回`Spine2D`动画模型文件的可用的外观列表。
	-- @param boneStr (string) 要获取外观的`Spine2D`文件名字符串。
	-- @return ({string}) 包含可用外观的字符串列表。
	getLooks: function(self: SpineClass, spineStr: string): {string}

	-- 返回`Spine2D`动画模型文件的可用的动画列表。
	-- @param boneStr (string) 要获取动画的`Spine2D`文件名字符串。
	-- @return ({string}) 包含可用动画的字符串列表。
	getAnimations: function(self: SpineClass, spineStr: string): {string}

	-- 使用指定的`Spine2D`字符串创建`Spine`的新实例。
	-- @param spineStr (string) 用于创建新实例的`Spine2D`文件名字符串。
	-- `Spine2D`文件名字符串可以是不带扩展名的文件路径，例如：“Spine/item”，也可以是带有所有相关文件的文件路径，例如 “Spine/item.skel|Spine/item.atlas” 或 “Spine/item.json|Spine/item.atlas”。
	-- @return (Spine) `Spine`的新实例。如果创建失败，则返回 nil。
	metamethod __call: function(self: SpineClass, spineStr: string): Spine | nil

	-- 使用指定的骨架文件和图集文件创建`Spine`的新实例。
	-- @param skelFile (string) 要加载的骨架文件的文件名。
	-- @param atlasFile (string) 要加载的图集文件的文件名。
	-- @return (Spine) `Spine`的新实例，具有指定的骨架文件和图集文件。如果创建失败，则返回 nil。
	metamethod __call: function(self: SpineClass, skelFile: string, atlasFile: string): Spine | nil
end

local spineClass: SpineClass
return spineClass
