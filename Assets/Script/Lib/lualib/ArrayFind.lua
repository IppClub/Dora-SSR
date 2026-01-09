local function __TS__ArrayFind(self, predicate, thisArg)
	for i = 1, #self do
		local elem = self[i]
		if predicate(thisArg, elem, i - 1, self) then
			return elem
		end
	end
	return nil
end
