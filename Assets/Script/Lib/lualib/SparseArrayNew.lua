local function __TS__SparseArrayNew(...)
	local sparseArray = {...}
	sparseArray.sparseLength = __TS__CountVarargs(...)
	return sparseArray
end
