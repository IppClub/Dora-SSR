local function __TS__ArrayForEach(self, callbackFn, thisArg)
	for i = 1, #self do
		callbackFn(thisArg, self[i], i - 1, self)
	end
end
