local Object = require("Object").Type
local Color = require("Color").Type
local Color3 = require("Color3").Type
local Texture2D = require("Texture2D").Type

-- A per-instance material slot owned by a Model3D instance.
local record Material3D
	embed Object

	-- The base color factor.
	baseColor: Color

	-- The emissive color factor.
	emissive: Color3

	-- The metallic factor.
	metallic: number

	-- The roughness factor.
	roughness: number

	-- Alpha mode: 0 opaque, 1 mask, 2 blend.
	alphaMode: integer

	-- The alpha cutoff used in mask mode.
	alphaCutoff: number

	-- Sets the base color texture.
	setBaseColorTexture: function(self: Material3D, texture: Texture2D)

	-- Clears the base color texture.
	clearBaseColorTexture: function(self: Material3D)

	-- Sets the metallic-roughness texture.
	setMetallicRoughnessTexture: function(self: Material3D, texture: Texture2D)

	-- Clears the metallic-roughness texture.
	clearMetallicRoughnessTexture: function(self: Material3D)

	-- Sets the normal texture.
	setNormalTexture: function(self: Material3D, texture: Texture2D)

	-- Clears the normal texture.
	clearNormalTexture: function(self: Material3D)

	-- Sets the emissive texture.
	setEmissiveTexture: function(self: Material3D, texture: Texture2D)

	-- Clears the emissive texture.
	clearEmissiveTexture: function(self: Material3D)

	-- Sets the occlusion texture.
	setOcclusionTexture: function(self: Material3D, texture: Texture2D)

	-- Clears the occlusion texture.
	clearOcclusionTexture: function(self: Material3D)
end

return Material3D
