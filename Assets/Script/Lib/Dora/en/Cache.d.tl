local Texture2D = require("Texture2D").Type

-- A singleton cache instance for various game resources.
local record Cache
	userdata

	-- An enum that defines the various types of resources that can be loaded into the cache.
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

	-- An enum that defines the various types of resources that can be safely unloaded from the cache.
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

	-- Loads a file into the cache with a blocking operation.
	-- @param filename (string) The name of the file to load.
	-- @return (boolean) True if the file was loaded successfully, false otherwise.
	load: function(self: Cache, filename: string): boolean

	-- Loads a file into the cache asynchronously.
	-- @usage
	-- thread(function()
	-- 	local success = Cache:loadAsync("file.png")
	-- 	if success then
	-- 		print("Game resource is loaded into memory")
	-- 	end
	-- end)
	-- @param filenames (string | {string}) The name of the file(s) to load.
	-- @param handler (function) [optional] A callback function that is invoked when the file is loaded. The progress parameter is a number between 0 and 1.
	-- @return (boolean) True if the files were loaded successfully, false otherwise.
	loadAsync: function(self: Cache, filename: string | {string}, handler?: function(progress: number)): boolean

	-- Updates the content of a file loaded in the cache.
	-- If the item of filename does not exist in the cache, a new file content will be added into the cache.
	-- @param filename (string) The name of the file to update.
	-- @param content (string) The new content for the file.
	update: function(self: Cache, filename: string, content: string)

	-- Updates the texture object of the specific filename loaded in the cache.
	-- If the texture object of filename does not exist in the cache, it will be added into the cache.
	-- @param filename (string) The name of the texture to update.
	-- @param texture (Texture2D) The new texture object for the file.
	update: function(self: Cache, filename: string, texture: Texture2D)

	-- Unloads a resource from the cache.
	-- @param type (ResourceTypeSafeUnload) The type of resource to unload.
	-- @return (boolean) True if the resource was unloaded successfully, false otherwise.
	unload: function(self: Cache, type: ResourceTypeSafeUnload): boolean

	-- Unloads a resource from the cache.
	-- @param filename (string) The name of the file to unload.
	-- @return (boolean) True if the resource was unloaded successfully, false otherwise.
	unload: function(self: Cache, filename: string): boolean

	-- Unloads all resources from the cache.
	unload: function(self: Cache)

	-- Removes all unused resources (not being referenced) of the given type from the cache.
	-- @param type (ResourceType) The type of resource to remove.
	removeUnused: function(self: Cache, type: ResourceType)

	-- Removes all unused resources (not being referenced) from the cache.
	removeUnused: function(self: Cache)
end

local cache: Cache
return cache
