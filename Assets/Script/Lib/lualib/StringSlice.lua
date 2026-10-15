local function __TS__StringSlice(self, start, ____end)
	if start == nil or start ~= start then
		start = 0
	end
	if ____end ~= ____end then
		____end = 0
	end
	if start >= 0 then
		start = start + 1
	end
	if ____end ~= nil and ____end < 0 then
		____end = ____end - 1
	end
	return string.sub(self, start, ____end)
end
