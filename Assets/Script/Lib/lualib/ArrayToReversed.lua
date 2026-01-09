local function __TS__ArrayToReversed(self)
	local copy = {__TS__Unpack(self)}
	__TS__ArrayReverse(copy)
	return copy
end
