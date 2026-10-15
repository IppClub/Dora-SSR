local function __TS__ObjectEntries(obj)
	local result = {}
	local len = 0
	for key in pairs(obj) do
		len = len + 1
		result[len] = {key, obj[key]}
	end
	return result
end
