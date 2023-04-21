-- 进行系统文件路径操作的类。
local record Path

	-- 从脚本模块名称中获得脚本的文件路径。
	-- @usage
	-- -- 在名字叫'init'的项目脚本程序入口文件中
	-- local scriptPath = Path:getScriptPath(...)
	-- -- 设置项目文件搜索路径
	-- Content:insertSearchPath(1, scriptPath)
	getScriptPath: function(self: Path, moduleName: string): string

	-- 输入: /a/b/c.TXT 输出: txt
	getExt: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: /a/b
	getPath: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: c
	getName: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: c.TXT
	getFilename: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT, /a 输出: b/c.TXT
	getRelative: function(self: Path, path: string, base: string): string

	-- 输入: /a/b/c.TXT, lua 输出: /a/b/c.lua
	replaceExt: function(self: Path, path: string, newExt: string): string

	-- 输入: /a/b/c.TXT, d 输出: /a/b/d.TXT
	replaceFilename: function(self: Path, path: string, newFile: string): string

	-- 输入: a, b, c.TXT 输出: a/b/c.TXT
	metamethod __call: function(self: Path, ...: string): string
end

local path: Path
return path
