--local View = require("View")
--View.scale = 2

local Content = require("Content")

Content:setSearchPaths {
	Content.writablePath.."Script",
	Content.writablePath.."Script/Lib",
	"Script",
	"Script/Lib"
}

require("moonscript")

require("Dev.entry")
