local function __TS__StringCharAt(self, pos)
	if pos ~= pos then
		pos = 0
	end
	if pos < 0 then
		return ""
	end
	return string.sub(self, pos + 1, pos + 1)
end
