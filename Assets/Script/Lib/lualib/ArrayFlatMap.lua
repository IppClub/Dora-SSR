local function __TS__ArrayFlatMap(self, callback, thisArg)
	local result = {}
	local len = 0
	for i = 1, #self do
		local value = callback(thisArg, self[i], i - 1, self)
		if __TS__ArrayIsArray(value) then
			for j = 1, #value do
				len = len + 1
				result[len] = value[j]
			end
		else
			len = len + 1
			result[len] = value
		end
	end
	return result
end
