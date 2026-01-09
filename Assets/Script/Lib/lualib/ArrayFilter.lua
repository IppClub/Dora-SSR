local function __TS__ArrayFilter(self, callbackfn, thisArg)
	local result = {}
	local len = 0
	for i = 1, #self do
		if callbackfn(thisArg, self[i], i - 1, self) then
			len = len + 1
			result[len] = self[i]
		end
	end
	return result
end
