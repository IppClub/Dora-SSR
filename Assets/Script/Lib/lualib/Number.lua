local function __TS__Number(value)
	local valueType = type(value)
	if valueType == "number" then
		return value
	elseif valueType == "string" then
		local numberValue = tonumber(value)
		if numberValue then
			return numberValue
		end
		if value == "Infinity" then
			return math.huge
		end
		if value == "-Infinity" then
			return -math.huge
		end
		local stringWithoutSpaces = string.gsub(value, "%s", "")
		if stringWithoutSpaces == "" then
			return 0
		end
		return 0 / 0
	elseif valueType == "boolean" then
		return value and 1 or 0
	else
		return 0 / 0
	end
end
