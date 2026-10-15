local function __TS__ArrayFlat(self, depth)
	if depth == nil then
		depth = 1
	end
	local result = {}
	local len = 0
	for i = 1, #self do
		local value = self[i]
		if depth > 0 and __TS__ArrayIsArray(value) then
			local toAdd
			if depth == 1 then
				toAdd = value
			else
				toAdd = __TS__ArrayFlat(value, depth - 1)
			end
			for j = 1, #toAdd do
				local val = toAdd[j]
				len = len + 1
				result[len] = val
			end
		else
			len = len + 1
			result[len] = value
		end
	end
	return result
end
