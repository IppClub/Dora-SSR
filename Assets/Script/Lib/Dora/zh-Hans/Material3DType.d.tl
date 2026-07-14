local Object = require("Object").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Texture2D = require("Texture2D").Type

-- 由 Model3D 实例持有的逐实例材质槽。
local record Material3D
	embed Object

	baseColor: Color
	emissive: Color3
	metallic: number
	roughness: number
	-- 透明模式：0 不透明，1 遮罩，2 混合。
	alphaMode: integer
	alphaCutoff: number
	setBaseColorTexture: function(self: Material3D, texture: Texture2D)
	clearBaseColorTexture: function(self: Material3D)
	setMetallicRoughnessTexture: function(self: Material3D, texture: Texture2D)
	clearMetallicRoughnessTexture: function(self: Material3D)
	setNormalTexture: function(self: Material3D, texture: Texture2D)
	clearNormalTexture: function(self: Material3D)
	setEmissiveTexture: function(self: Material3D, texture: Texture2D)
	clearEmissiveTexture: function(self: Material3D)
	setOcclusionTexture: function(self: Material3D, texture: Texture2D)
	clearOcclusionTexture: function(self: Material3D)
end

return Material3D
