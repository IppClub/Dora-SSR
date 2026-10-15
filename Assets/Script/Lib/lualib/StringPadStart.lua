local function __TS__StringPadStart(self, maxLength, fillString)
	if fillString == nil then
		fillString = " "
	end
	if maxLength ~= maxLength then
		maxLength = 0
	end
	if maxLength == -math.huge or maxLength == math.huge then
		error("Invalid string length", 0)
	end
	if #self >= maxLength or #fillString == 0 then
		return self
	end
	maxLength = maxLength - #self
	if maxLength > #fillString then
		fillString = fillString .. string.rep(
			fillString,
			math.floor(maxLength / #fillString)
		)
	end
	return string.sub(
		fillString,
		1,
		math.floor(maxLength)
	) .. self
end
