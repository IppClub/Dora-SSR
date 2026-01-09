local function __TS__StringIncludes(self, searchString, position)
	if not position then
		position = 1
	else
		position = position + 1
	end
	local index = string.find(self, searchString, position, true)
	return index ~= nil
end
