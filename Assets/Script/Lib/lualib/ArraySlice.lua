local function __TS__ArraySlice(self, first, last)
	local len = #self
	first = first or 0
	if first < 0 then
		first = len + first
		if first < 0 then
			first = 0
		end
	else
		if first > len then
			first = len
		end
	end
	last = last or len
	if last < 0 then
		last = len + last
		if last < 0 then
			last = 0
		end
	else
		if last > len then
			last = len
		end
	end
	local out = {}
	first = first + 1
	last = last + 1
	local n = 1
	while first < last do
		out[n] = self[first]
		first = first + 1
		n = n + 1
	end
	return out
end
