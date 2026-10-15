local function __TS__StringTrimStart(self)
	local start = 1
	local finish = #self
	while start <= finish do
		local byte = string.byte(self, start)
		if byte == 9 or byte == 10 or byte == 11 or byte == 12 or byte == 13 or byte == 32 then
			start = start + 1
		elseif byte == 194 and string.byte(self, start + 1) == 160 then
			start = start + 2
		elseif byte == 239 and string.byte(self, start + 1) == 187 and string.byte(self, start + 2) == 191 then
			start = start + 3
		else
			break
		end
	end
	return string.sub(self, start)
end
