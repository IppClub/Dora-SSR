local function __TS__StringTrimEnd(self)
	local result = string.gsub(self, "[%s ﻿]*$", "")
	return result
end
