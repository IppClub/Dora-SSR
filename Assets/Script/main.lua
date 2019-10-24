local Content = require("Content")

Content.searchPaths = {
	Content.writablePath.."Script",
	Content.writablePath.."Script/Lib",
	"Script",
	"Script/Lib",
	"Image"
}
local code, err = moontolua([[
return for sub in list
	while true
	  x
]], {
  line_number = false
})
print("code: \n" .. tostring(code) .. "\nerr: \n" .. tostring(err))
require("Dev.Entry")
