local Object = require("Object").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Texture2D = require("Texture2D").Type

-- A per-instance material slot owned by a Model3D instance.
local record Material3D
	embed Object

	baseColor: Color
	emissive: Color3
	metallic: number
	roughness: number
	-- Alpha mode: 0 opaque, 1 mask, 2 blend.
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
