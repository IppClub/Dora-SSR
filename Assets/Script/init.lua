local Content = require("Content")
local Path = require("Path")

Content.searchPaths = {
	Path(Content.writablePath, "Build", "Script"),
	Path(Content.writablePath, "Build", "Script", "Lib"),
	"Script",
	Path("Script", "Lib"),
	Path("Script", "Lib", "Dora"),
	"Image",
	"Spine",
	"DragonBones",
}

local yue = require("yue")
yue("Dev.Entry")

