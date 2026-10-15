local function __TS__ArrayEvery(self, callbackfn, thisArg)
	for i = 1, #self do
		if not callbackfn(thisArg, self[i], i - 1, self) then
			return false
		end
	end
	return true
end
