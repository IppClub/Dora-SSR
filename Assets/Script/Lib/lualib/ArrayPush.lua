local function __TS__ArrayPush(self, ...)
	local items = {...}
	local len = #self
	for i = 1, #items do
		len = len + 1
		self[len] = items[i]
	end
	return len
end
