local Content = require("Content")

Content.searchPaths = {
	Content.writablePath.."Script",
	Content.writablePath.."Script/Lib",
	"Script",
	"Script/Lib",
	"Image",
	Content.writablePath
}

require("Dev.Entry")

print(moontolua([[
export default {flag:1, value:"x"}
]],{reserve_line_number=false}))
