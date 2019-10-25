local Content = require("Content")

Content.searchPaths = {
	Content.writablePath.."Script",
	Content.writablePath.."Script/Lib",
	"Script",
	"Script/Lib",
	"Image"
}

require("Dev.Entry")
