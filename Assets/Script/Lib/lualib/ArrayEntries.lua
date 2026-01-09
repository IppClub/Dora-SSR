local function __TS__ArrayEntries(array)
	local key = 0
	return {
		[Symbol.iterator] = function(self)
			return self
		end,
		next = function(self)
			local result = {done = array[key + 1] == nil, value = {key, array[key + 1]}}
			key = key + 1
			return result
		end
	}
end
