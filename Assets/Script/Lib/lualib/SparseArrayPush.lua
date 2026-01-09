local function __TS__SparseArrayPush(sparseArray, ...)
	local args = {...}
	local argsLen = __TS__CountVarargs(...)
	local listLen = sparseArray.sparseLength
	for i = 1, argsLen do
		sparseArray[listLen + i] = args[i]
	end
	sparseArray.sparseLength = listLen + argsLen
end
