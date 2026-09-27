local function __TS__StringTrim(self)
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
	while finish >= start do
		local byte = string.byte(self, finish)
		if byte == 9 or byte == 10 or byte == 11 or byte == 12 or byte == 13 or byte == 32 then
			finish = finish - 1
		elseif byte == 160 and finish >= start + 1 and string.byte(self, finish - 1) == 194 then
			finish = finish - 2
		elseif byte == 191 and finish >= start + 2 and string.byte(self, finish - 1) == 187 and string.byte(self, finish - 2) == 239 then
			finish = finish - 3
		else
			break
		end
	end
	return string.sub(self, start, finish)
end
