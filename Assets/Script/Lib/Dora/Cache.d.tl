local Texture2D = require("Texture2D").Type
local record Cache
	enum ResourceType
		"Bone"
		"Spine"
		"Texture"
		"SVG"
		"Clip"
		"Frame"
		"Model"
		"Particle"
		"Shader"
		"Font"
		"Sound"
	end
	enum ResourceTypeSafeUnload
		"Texture"
		"SVG"
		"Clip"
		"Frame"
		"Model"
		"Particle"
		"Shader"
		"Font"
		"Sound"
		"Spine"
	end
	load: function(self: Cache, filename: string): boolean
	loadAsync: function(self: Cache, filename: string)
	update: function(self: Cache, filename: string, content: string)
	update: function(self: Cache, filename: string, texture: Texture2D)
	unload: function(self: Cache, type: ResourceTypeSafeUnload): boolean
	unload: function(self: Cache, filename: string): boolean
	removeUnused: function(self: Cache)
	removeUnused: function(self: Cache, type: ResourceType)
end
local cache: Cache
return cache
