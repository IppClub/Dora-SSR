local function __TS__LuaIteratorSpread(self, state, firstKey)
	local results = {}
	local key, value = self(state, firstKey)
	while key do
		results[#results + 1] = {key, value}
		key, value = self(state, key)
	end
	return __TS__Unpack(results)
end
