-- Helper class for file path operations.
local record Path

	-- Gets script running path from a module name.
	-- @usage
	-- -- in the script entry file named 'init'
	-- local scriptPath = Path:getScriptPath(...)
	-- -- set up the project search paths
	-- Content:insertSearchPath(1, scriptPath)
	-- @param moduleName (string) The input module name.
	-- @return (string) The module path for script searching.
	getScriptPath: function(self: Path, moduleName: string): string

	-- Input: /a/b/c.TXT output: txt
	-- @param path (string) The input file path.
	-- @return (string) The input file's extension.
	getExt: function(self: Path, path: string): string

	-- Input: /a/b/c.TXT output: /a/b
	-- @param path (string) The input file path.
	-- @return (string) The input file's parent path.
	getPath: function(self: Path, path: string): string

	-- Input: /a/b/c.TXT output: c
	-- @param path (string) The input file path.
	-- @return (string) The input file's name without extension.
	getName: function(self: Path, path: string): string

	-- Input: /a/b/c.TXT output: c.TXT
	-- @param path (string) The input file path.
	-- @return (string) The input file's name.
	getFilename: function(self: Path, path: string): string

	-- Input: /a/b/c.TXT, base: /a output: b/c.TXT
	-- @param path (string) The input file path.
	-- @param base (string) The target file path.
	-- @return (string) The relative from input file to target file.
	getRelative: function(self: Path, path: string, base: string): string

	-- Input: /a/b/c.TXT, lua output: /a/b/c.lua
	-- @param path (string) The input file path.
	-- @param newExt (string) The new file extention to add to file path.
	-- @return (string) The new file path.
	replaceExt: function(self: Path, path: string, newExt: string): string

	-- Input: /a/b/c.TXT, d output: /a/b/d.TXT
	-- @param path (string) The input file path.
	-- @param newFile (string) The new filename to replace.
	-- @return (string) The new file path.
	replaceFilename: function(self: Path, path: string, newFile: string): string

	-- input: a, b, c.TXT output: a/b/c.TXT
	-- @param ... (string) The segments to be joined as a new file path.
	-- @return (string) The new file path.
	metamethod __call: function(self: Path, ...: string): string
end

local path: Path
return path
