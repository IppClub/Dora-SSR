local __TS__NumberToString
do
	local radixChars = "0123456789abcdefghijklmnopqrstuvwxyz"
	function __TS__NumberToString(self, radix)
		if radix == nil or radix == 10 or self == math.huge or self == -math.huge or self ~= self then
			return tostring(self)
		end
		radix = math.floor(radix)
		if radix < 2 or radix > 36 then
			error("toString() radix argument must be between 2 and 36", 0)
		end
		local integer, fraction = __TS__MathModf(math.abs(self))
		local result = ""
		if radix == 8 then
			result = string.format("%o", integer)
		elseif radix == 16 then
			result = string.format("%x", integer)
		else
			repeat
				do
					result = __TS__StringAccess(radixChars, integer % radix) .. result
					integer = math.floor(integer / radix)
				end
			until not (integer ~= 0)
		end
		if fraction ~= 0 then
			result = result .. "."
			local delta = 1e-16
			repeat
				do
					fraction = fraction * radix
					delta = delta * radix
					local digit = math.floor(fraction)
					result = result .. __TS__StringAccess(radixChars, digit)
					fraction = fraction - digit
				end
			until not (fraction >= delta)
		end
		if self < 0 then
			result = "-" .. result
		end
		return result
	end
end
