local record Path
	getExt: function(path: string): string
	getPath: function(path: string): string
	getName: function(path: string): string
	getFilename: function(path: string): string
	replaceExt: function(path: string, newExt: string): string
	replaceFilename: function(path: string, newFile: string): string
	-- file paths concatation
	metamethod __call: function(self: Path, ...: string): string
end
local path: Path
return path
