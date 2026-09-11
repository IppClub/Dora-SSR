local Object = require("Object").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Texture2D = require("Texture2D").Type

-- 由 Model3D 实例持有的逐实例材质槽。
local record Material3D
	embed Object

	-- 基础颜色系数。
	baseColor: Color

	-- 自发光颜色系数。
	emissive: Color3

	-- 金属度系数。
	metallic: number

	-- 粗糙度系数。
	roughness: number

	-- 透明模式：0 不透明，1 遮罩，2 混合。
	alphaMode: integer

	-- 遮罩模式使用的透明度阈值。
	alphaCutoff: number

	-- 设置基础颜色纹理。
	setBaseColorTexture: function(self: Material3D, texture: Texture2D)

	-- 清除基础颜色纹理。
	clearBaseColorTexture: function(self: Material3D)

	-- 设置金属度与粗糙度纹理。
	setMetallicRoughnessTexture: function(self: Material3D, texture: Texture2D)

	-- 清除金属度与粗糙度纹理。
	clearMetallicRoughnessTexture: function(self: Material3D)

	-- 设置法线纹理。
	setNormalTexture: function(self: Material3D, texture: Texture2D)

	-- 清除法线纹理。
	clearNormalTexture: function(self: Material3D)

	-- 设置自发光纹理。
	setEmissiveTexture: function(self: Material3D, texture: Texture2D)

	-- 清除自发光纹理。
	clearEmissiveTexture: function(self: Material3D)

	-- 设置环境光遮蔽纹理。
	setOcclusionTexture: function(self: Material3D, texture: Texture2D)

	-- 清除环境光遮蔽纹理。
	clearOcclusionTexture: function(self: Material3D)
end

return Material3D
