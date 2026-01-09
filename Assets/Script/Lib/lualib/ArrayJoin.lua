local function __TS__ArrayJoin(self, separator)
	if separator == nil then
		separator = ","
	end
	local parts = {}
	for i = 1, #self do
		parts[i] = tostring(self[i])
	end
	return table.concat(parts, separator)
end
