local function __TS__ArrayToSpliced(self, start, deleteCount, ...)
	local copy = {__TS__Unpack(self)}
	__TS__ArraySplice(copy, start, deleteCount, ...)
	return copy
end
