local function __TS__StringAccess(self, index)
	if index >= 0 and index < #self then
		return string.sub(self, index + 1, index + 1)
	end
end
