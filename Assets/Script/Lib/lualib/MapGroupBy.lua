local function __TS__MapGroupBy(items, keySelector)
	local result = __TS__New(Map)
	local i = 0
	for ____, item in __TS__Iterator(items) do
		local key = keySelector(nil, item, i)
		if result:has(key) then
			local ____temp_0 = result:get(key)
			____temp_0[#____temp_0 + 1] = item
		else
			result:set(key, {item})
		end
		i = i + 1
	end
	return result
end
