local Content = require("Content")

Content:addSearchPath("Script")
Content:addSearchPath("Script/Lib")

local moon = require("moonscript")

debug.traceback = function(err)
	local STP = require("StackTracePlus")
	STP.dump_locals = false
	STP.simplified = true
	return STP.stacktrace(err, 1)
end

require("Dev.entry")
