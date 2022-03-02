local record Path
	-- input: /a/b/c.TXT output: txt
	getExt: function(path: string): string
	-- input: /a/b/c.TXT output: /a/b
	getPath: function(path: string): string
	-- input: /a/b/c.TXT output: c
	getName: function(path: string): string
	-- input: /a/b/c.TXT output: c.TXT
	getFilename: function(path: string): string
	-- input: /a/b/c.TXT, lua output: /a/b/c.lua
	replaceExt: function(path: string, newExt: string): string
	-- input: /a/b/c.TXT, d output: /a/b/d.TXT
	replaceFilename: function(path: string, newFile: string): string
	-- input: a, b, c.TXT output: a/b/c.TXT
	metamethod __call: function(self: Path, ...: string): string
end
local path: Path
return path
