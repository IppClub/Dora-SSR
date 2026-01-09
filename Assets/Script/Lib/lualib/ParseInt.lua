local __TS__ParseInt
do
	local parseIntBasePattern = "0123456789aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTvVwWxXyYzZ"
	function __TS__ParseInt(numberString, base)
		if base == nil then
			base = 10
			local hexMatch = __TS__Match(numberString, "^%s*-?0[xX]")
			if hexMatch ~= nil then
				base = 16
				numberString = (__TS__Match(hexMatch, "-")) and "-" .. __TS__StringSubstring(numberString, #hexMatch) or __TS__StringSubstring(numberString, #hexMatch)
			end
		end
		if base < 2 or base > 36 then
			return 0 / 0
		end
		local allowedDigits = base <= 10 and __TS__StringSubstring(parseIntBasePattern, 0, base) or __TS__StringSubstring(parseIntBasePattern, 0, 10 + 2 * (base - 10))
		local pattern = ("^%s*(-?[" .. allowedDigits) .. "]*)"
		local number = tonumber((__TS__Match(numberString, pattern)), base)
		if number == nil then
			return 0 / 0
		end
		if number >= 0 then
			return math.floor(number)
		else
			return math.ceil(number)
		end
	end
end
