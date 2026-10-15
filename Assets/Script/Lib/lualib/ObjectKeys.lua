local function __TS__ObjectKeys(obj)
	local result = {}
	local len = 0
	for key in pairs(obj) do
		len = len + 1
		result[len] = key
	end
	return result
end
