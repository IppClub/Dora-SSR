local function __TS__ParseFloat(numberString)
	local infinityMatch = __TS__Match(numberString, "^%s*(-?Infinity)")
	if infinityMatch ~= nil then
		return __TS__StringAccess(infinityMatch, 0) == "-" and -math.huge or math.huge
	end
	local number = tonumber((__TS__Match(numberString, "^%s*(-?%d+%.?%d*)")))
	return number or 0 / 0
end
