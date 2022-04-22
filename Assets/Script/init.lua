local Content = require("Content")
local Path = require("Path")

Content.searchPaths = {
	Path(Content.writablePath, "Build", "Script"),
	Path(Content.writablePath, "Build", "Script", "Lib"),
	"Script",
	Path("Script", "Lib"),
	Path("Script", "Lib", "Dora"),
}

require("Dev.Entry")

print(require("yue").to_lua[[
newtb = {...tb.123, ...tb2}
]])
