local function __TS__StringTrimStart(self)
	local result = string.gsub(self, "^[%s ﻿]*", "")
	return result
end
