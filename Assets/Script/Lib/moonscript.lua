debug.traceback = function(err)
	local STP = require("StackTracePlus")
	STP.dump_locals = false
	STP.simplified = true
	return STP.stacktrace(err, 1)
end

return require "moonscript.init"
