local function __TS__ArrayFindIndex(self, callbackFn, thisArg)
	for i = 1, #self do
		if callbackFn(thisArg, self[i], i - 1, self) then
			return i - 1
		end
	end
	return -1
end
