local function __TS__ArraySome(self, callbackfn, thisArg)
	for i = 1, #self do
		if callbackfn(thisArg, self[i], i - 1, self) then
			return true
		end
	end
	return false
end
