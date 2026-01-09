local function __TS__ArrayIncludes(self, searchElement, fromIndex)
	if fromIndex == nil then
		fromIndex = 0
	end
	local len = #self
	local k = fromIndex
	if fromIndex < 0 then
		k = len + fromIndex
	end
	if k < 0 then
		k = 0
	end
	for i = k + 1, len do
		if self[i] == searchElement then
			return true
		end
	end
	return false
end
