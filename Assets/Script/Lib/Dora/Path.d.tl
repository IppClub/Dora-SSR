local record Path
	getScriptPath: function(self: Path, moduleName: string): string
	-- input: /a/b/c.TXT output: txt
	getExt: function(self: Path, path: string): string
	-- input: /a/b/c.TXT output: /a/b
	getPath: function(self: Path, path: string): string
	-- input: /a/b/c.TXT output: c
	getName: function(self: Path, path: string): string
	-- input: /a/b/c.TXT output: c.TXT
	getFilename: function(self: Path, path: string): string
	-- input: /a/b/c.TXT, lua output: /a/b/c.lua
	replaceExt: function(self: Path, path: string, newExt: string): string
	-- input: /a/b/c.TXT, d output: /a/b/d.TXT
	replaceFilename: function(self: Path, path: string, newFile: string): string
	-- input: a, b, c.TXT output: a/b/c.TXT
	metamethod __call: function(self: Path, ...: string): string
end
local path: Path
return path
