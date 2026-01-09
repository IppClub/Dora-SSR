local function __TS__StringEndsWith(self, searchString, endPosition)
	if endPosition == nil or endPosition > #self then
		endPosition = #self
	end
	return string.sub(self, endPosition - #searchString + 1, endPosition) == searchString
end
