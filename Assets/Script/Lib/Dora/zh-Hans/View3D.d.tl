local Node3D = require("Node3D").Type
local Node = require("Node").Type

-- 用于在 2D 场景树中渲染 3D 内容的类。
local record View3D

	-- 继承自 `Node`。
	embed Node

	-- 3D 场景根节点。
	const scene: Node3D

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
