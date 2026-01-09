local function __TS__ArraySort(self, compareFn)
	if compareFn ~= nil then
		table.sort(
			self,
			function(a, b) return compareFn(nil, a, b) < 0 end
		)
	else
		table.sort(self)
	end
	return self
end
