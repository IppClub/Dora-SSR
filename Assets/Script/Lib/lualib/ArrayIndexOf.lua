local function __TS__ArrayIndexOf(self, searchElement, fromIndex)
	if fromIndex == nil then
		fromIndex = 0
	end
	local len = #self
	if len == 0 then
		return -1
	end
	if fromIndex >= len then
		return -1
	end
	if fromIndex < 0 then
		fromIndex = len + fromIndex
		if fromIndex < 0 then
			fromIndex = 0
		end
	end
	for i = fromIndex + 1, len do
		if self[i] == searchElement then
			return i - 1
		end
	end
	return -1
end
