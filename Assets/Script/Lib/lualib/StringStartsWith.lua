local function __TS__StringStartsWith(self, searchString, position)
	if position == nil or position < 0 then
		position = 0
	end
	return string.sub(self, position + 1, #searchString + position) == searchString
end
