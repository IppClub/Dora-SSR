local Node3D = require("Node3D").Type
local Node = require("Node").Type
local Vec2 = require("Vec2").Type
local Vec3 = require("Vec3").Type
local Model3D = require("Model3D").Type
local RenderStats3D = require("RenderStats3DType")

-- 用于在 2D 场景树中渲染 3D 内容的类。
local record View3D

	-- 继承自 `Node`。
	embed Node

	-- 3D 场景根节点。
	const scene: Node3D

	-- 最近一次3D渲染与当前3D资源注册表的统计信息。
	const stats: RenderStats3D

	-- 是否绘制当前世界坐标 AABB 调试线框。
	showAABB: boolean

	-- 阴影贴图边长。该值会归一化为 256、512、1024、2048 或 4096。
	shadowMapSize: number

	-- 返回穿过视图坐标点的拾取射线世界坐标起点。
	getRayOrigin: function(self: View3D, viewPoint: Vec2): Vec3

	-- 返回穿过视图坐标点的拾取射线世界坐标方向。
	getRayDirection: function(self: View3D, viewPoint: Vec2): Vec3

	-- 返回与视图坐标点相交的最近可见模型。
	pick: function(self: View3D, viewPoint: Vec2): Model3D | nil

	-- 加载用于基于图像照明的环境贴图。
	-- @param path (string) 环境贴图路径。空字符串会清除环境贴图。
	-- @return (boolean) 成功加载或清除时返回 true。
	setEnvironmentMap: function(self: View3D, path: string): boolean

	-- 设置环境光漫反射、镜面反射和曝光强度。
	-- @param diffuse (number) 漫反射光照强度。
	-- @param specular (number) 镜面反射光照强度。
	-- @param exposure (number) [可选] 曝光值。默认为 1.0。
	setEnvironmentIntensity: function(
		self: View3D,
		diffuse: number,
		specular: number,
		exposure?: number --[[1.0]]
	)
end

local record View3DClass
	type Type = View3D

	-- 创建新的 View3D 对象。
	-- @return (View3D) 新的 View3D 对象。
	metamethod __call: function(self: View3DClass): View3D
end

local view3DClass: View3DClass
return view3DClass
