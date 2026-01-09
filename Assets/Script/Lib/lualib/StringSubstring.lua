local function __TS__StringSubstring(self, start, ____end)
	if ____end ~= ____end then
		____end = 0
	end
	if ____end ~= nil and start > ____end then
		start, ____end = ____end, start
	end
	if start >= 0 then
		start = start + 1
	else
		start = 1
	end
	if ____end ~= nil and ____end < 0 then
		____end = 0
	end
	return string.sub(self, start, ____end)
end
