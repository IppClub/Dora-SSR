local Node3D = require("Node3D").Type
local Vec3 = require("Vec3").Type
local type Material3D = require("Material3DType")

-- 用于渲染 glTF 3D 模型的类。
local record Model3D

	-- 继承自 `Node3D`。
	embed Node3D

	-- 当前动画的播放速度倍率。
	speed: number

	-- 当前动画的时长，单位为秒。
	const duration: number

	-- 当前动画已经播放的时间，单位为秒。
	const elapsed: number

	-- 当前是否正在播放动画。
	const playing: boolean

	-- 当前动画是否暂停。
	const paused: boolean

	-- 此模型中的动画片段数量。
	const animationCount: integer

	-- 当前实例中的材质槽数量。
	const materialCount: integer

	-- 按从零开始的索引获取动画名称。
	getAnimationName: function(self: Model3D, index: integer): string

	-- 检查是否存在指定名称的导入 glTF 节点。
	hasNode: function(self: Model3D, name: string): boolean

	-- 将用户持有的 Node3D 挂到指定导入节点下。
	attachToNode: function(self: Model3D, name: string, child: Node3D): boolean

	-- 获取当前模型空间包围盒的最小点。
	getLocalBoundsMin: function(self: Model3D): Vec3

	-- 获取当前模型空间包围盒的最大点。
	getLocalBoundsMax: function(self: Model3D): Vec3

	-- 获取当前世界空间包围盒的最小点。
	getWorldBoundsMin: function(self: Model3D): Vec3

	-- 获取当前世界空间包围盒的最大点。
	getWorldBoundsMax: function(self: Model3D): Vec3

	-- 按从零开始的索引获取逐实例材质槽。
	getMaterial: function(self: Model3D, index: integer): Material3D | nil

	-- 按名称播放动画。
	-- @param name (string) [可选] 动画名称。省略时使用默认动画。
	-- @param loop (boolean) [可选] 动画是否循环播放。默认为 false。
	-- @return (number) 动画时长，单位为秒。未找到时返回 0。
	play: function(self: Model3D, name?: string, loop?: boolean --[[false]]): number

	-- 停止当前动画。
	stop: function(self: Model3D)

	-- 暂停当前动画。
	pause: function(self: Model3D)

	-- 恢复暂停的动画。
	resume: function(self: Model3D)
end

local record Model3DClass
	type Type = Model3D

	-- 从模型文件路径创建新的 Model3D 对象。
	-- @param path (string) 模型文件路径。
	-- @return (Model3D) 新的 Model3D 对象，加载失败时返回 nil。
	metamethod __call: function(self: Model3DClass, path: string): Model3D | nil
end

local model3DClass: Model3DClass
return model3DClass
