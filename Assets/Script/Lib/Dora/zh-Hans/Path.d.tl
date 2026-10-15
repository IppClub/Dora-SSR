-- 进行系统文件路径操作的类。
local record Path

	-- 从脚本模块名称中获得脚本的文件路径。
	-- @usage
	-- -- 在名字叫'init'的项目脚本程序入口文件中
	-- local scriptPath = Path:getScriptPath(...)
	-- -- 设置项目文件搜索路径
	-- Content:insertSearchPath(1, scriptPath)
	-- @param moduleName (string) 脚本模块的名称。
	-- @return (string) 脚本模块的路径。
	getScriptPath: function(self: Path, moduleName: string): string

	-- 输入: /a/b/c.TXT 输出: txt
	-- @param path (string) 要处理的文件路径。
	-- @return (string) 文件扩展名。
	getExt: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: /a/b
	-- @param path (string) 要处理的文件路径。
	-- @return (string) 获得的父级文件路径。
	getPath: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: c
	-- @param path (string) 要处理的文件路径。
	-- @return (string) 不包含扩展名的文件名。
	getName: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT 输出: c.TXT
	-- @param path (string) 要处理的文件路径。
	-- @return (string) 文件名。
	getFilename: function(self: Path, path: string): string

	-- 输入: /a/b/c.TXT, /a 输出: b/c.TXT
	-- @param path (string) 要处理的文件路径。
	-- @param base (string) 要取得相对路径的基础文件路径。
	-- @return (string) 相对文件路径。
	getRelative: function(self: Path, path: string, base: string): string

	-- 输入: /a/b/c.TXT, lua 输出: /a/b/c.lua
	-- @param path (string) 要处理的文件路径。
	-- @param newExt (string) 要替换的新文件扩展名。
	-- @return (string) 处理后的文件路径。
	replaceExt: function(self: Path, path: string, newExt: string): string

	-- 输入: /a/b/c.TXT, d 输出: /a/b/d.TXT
	-- @param path (string) 要处理的文件路径。
	-- @param newFile (string) 要替换的新文件名。
	-- @return (string) 处理后的文件路径。
	replaceFilename: function(self: Path, path: string, newFile: string): string

	-- 输入: a, b, c.TXT 输出: a/b/c.TXT
	-- @param ... (string) 要拼接成新文件路径的文件名分段。
	-- @return (string) 新的文件路径。
	metamethod __call: function(self: Path, ...: string): string
end

local path: Path
return path
