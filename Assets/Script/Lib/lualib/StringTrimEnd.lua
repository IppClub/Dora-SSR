local function __TS__StringTrimEnd(self)
	local finish = #self
	while finish >= 1 do
		local byte = string.byte(self, finish)
		if byte == 9 or byte == 10 or byte == 11 or byte == 12 or byte == 13 or byte == 32 then
			finish = finish - 1
		elseif byte == 160 and finish >= 2 and string.byte(self, finish - 1) == 194 then
			finish = finish - 2
		elseif byte == 191 and finish >= 3 and string.byte(self, finish - 1) == 187 and string.byte(self, finish - 2) == 239 then
			finish = finish - 3
		else
			break
		end
	end
	return string.sub(self, 1, finish)
end
