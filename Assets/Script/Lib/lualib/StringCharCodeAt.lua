local function __TS__StringCharCodeAt(self, index)
	if index ~= index then
		index = 0
	end
	if index < 0 then
		return 0 / 0
	end
	return string.byte(self, index + 1) or 0 / 0
end
