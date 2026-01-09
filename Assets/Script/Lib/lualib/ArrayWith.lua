local function __TS__ArrayWith(self, index, value)
	local copy = {__TS__Unpack(self)}
	copy[index + 1] = value
	return copy
end
