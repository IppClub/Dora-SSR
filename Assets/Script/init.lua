local Content = require("Content")
local Path = require("Path")

Content.searchPaths = {
	Path(Content.writablePath, "Script"),
	Path(Content.writablePath, "Script", "Lib"),
	"Script",
	Path("Script", "Lib"),
	"Image",
	"Spine",
	"Production",
	Path("Production", "Script"),
	Path("Production", "Spine"),
	Content.writablePath
}

local moonp = require("moonp")
moonp("Dev.Entry")
