local Texture2D = require("Texture2D").Type

-- 用于管理各种游戏资源缓存的单例类。
local record Cache
	userdata

	-- 可以被缓存的各种资源类型。
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

	-- 可以从缓存中被安全卸载的各种资源类型。
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

	-- 使用阻塞的操作将资源文件加载到缓存中。
	-- @param filename (string) 要加载的资源文件的名称。
	-- @return (boolean) 如果资源文件成功加载，则返回 true，否则返回 false。
	load: function(self: Cache, filename: string): boolean

	-- 使用异步方式将资源文件加载到缓存中。
	-- @usage
	-- thread(function()
	-- 	local success = Cache:loadAsync("file.png")
	-- 	if success then
	-- 		print("游戏资源已加载到内存中")
	-- 	end
	-- end)
	-- @param filename (string | {string}) 要加载的资源文件的名称。
	-- @param handler (function) [可选] 加载进度回调函数。progress 参数是一个介于0和1之间的数字，表示加载进度的百分比。
	-- @return (boolean) 如果资源文件成功加载，则返回 true，否则返回 false。
	loadAsync: function(self: Cache, filename: string | {string}, handler?: function(progress: number)): boolean

	-- 更新缓存中已加载资源文件的内容。
	-- 如果资源文件名称对应的项不存在于缓存中，则会将新资源内容添加到缓存中。
	-- @param filename (string) 要更新的资源文件名称。
	-- @param content (string) 新的资源内容。
	update: function(self: Cache, filename: string, content: string)

	-- 更新缓存中指定文件名的纹理对象。
	-- 如果 filename 对应的纹理对象不存在于缓存中，则将其添加到缓存中。
	-- @param filename (string) 要更新的纹理的名称。
	-- @param texture (Texture2D) 文件的新纹理对象。
	update: function(self: Cache, filename: string, texture: Texture2D)

	-- 从缓存中强制卸载一类资源。
	-- @param type (ResourceTypeSafeUnload) 要卸载的资源类型。
	-- @return (boolean) 如果资源成功卸载，则返回 true，否则返回 false。
	unload: function(self: Cache, type: ResourceTypeSafeUnload): boolean

	-- 从缓存中强制卸载一个资源文件。
	-- @param filename (string) 要卸载的资源文件名称。
	-- @return (boolean) 如果资源文件成功被卸载，则返回 true，否则返回 false。
	unload: function(self: Cache, filename: string): boolean

	-- 从缓存中强制卸载所有资源文件。
	unload: function(self: Cache)

	-- 按资源类型从缓存中删除所有未被使用（未被引用）的资源。
	-- @param type (ResourceType) 要删除的资源类型。
	removeUnused: function(self: Cache, type: ResourceType)

	-- 从缓存中删除所有未被使用（未被引用）的资源。
	removeUnused: function(self: Cache)
end

local cache: Cache
return cache
