local function __TS__SparseArraySpread(sparseArray)
	local _unpack = unpack or table.unpack
	return _unpack(sparseArray, 1, sparseArray.sparseLength)
end
