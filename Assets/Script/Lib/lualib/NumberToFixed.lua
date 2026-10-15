local function __TS__NumberToFixed(self, fractionDigits)
	if math.abs(self) >= 1e+21 or self ~= self then
		return tostring(self)
	end
	local f = math.floor(fractionDigits or 0)
	if f < 0 or f > 99 then
		error("toFixed() digits argument must be between 0 and 99", 0)
	end
	return string.format(
		("%." .. tostring(f)) .. "f",
		self
	)
end
