local function __TS__StringTrim(self)
	local result = string.gsub(self, "^[%s ﻿]*(.-)[%s ﻿]*$", "%1")
	return result
end
