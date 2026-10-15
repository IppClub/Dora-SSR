local function __TS__ArrayWith(self, index, value)
	local relativeIndex = index < 0 and #self + index or index
	if relativeIndex < 0 or relativeIndex >= #self then
		error("Invalid index " .. tostring(index), 0)
	end
	local copy = {__TS__Unpack(self)}
	copy[relativeIndex + 1] = value
	return copy
end
