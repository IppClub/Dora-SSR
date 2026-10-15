local function __TS__ObjectRest(target, usedProperties)
	local result = {}
	for property in pairs(target) do
		if not usedProperties[property] then
			result[property] = target[property]
		end
	end
	return result
end
