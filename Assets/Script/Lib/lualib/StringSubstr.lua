local function __TS__StringSubstr(self, from, length)
	if from ~= from then
		from = 0
	end
	if length ~= nil then
		if length ~= length or length <= 0 then
			return ""
		end
		length = length + from
	end
	if from >= 0 then
		from = from + 1
	end
	return string.sub(self, from, length)
end
