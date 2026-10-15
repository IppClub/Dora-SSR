local function __TS__ArrayUnshift(self, ...)
	local items = {...}
	local numItemsToInsert = #items
	if numItemsToInsert == 0 then
		return #self
	end
	for i = #self, 1, -1 do
		self[i + numItemsToInsert] = self[i]
	end
	for i = 1, numItemsToInsert do
		self[i] = items[i]
	end
	return #self
end
