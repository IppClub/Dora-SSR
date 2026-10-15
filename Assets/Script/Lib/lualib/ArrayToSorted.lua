local function __TS__ArrayToSorted(self, compareFn)
	local copy = {__TS__Unpack(self)}
	__TS__ArraySort(copy, compareFn)
	return copy
end
