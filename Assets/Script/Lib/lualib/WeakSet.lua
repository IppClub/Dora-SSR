local WeakSet
do
	WeakSet = __TS__Class()
	WeakSet.name = "WeakSet"
	function WeakSet.prototype.____constructor(self, values)
		self[Symbol.toStringTag] = "WeakSet"
		self.items = {}
		setmetatable(self.items, {__mode = "k"})
		if values == nil then
			return
		end
		local iterable = values
		if iterable[Symbol.iterator] then
			local iterator = iterable[Symbol.iterator](iterable)
			while true do
				local result = iterator:next()
				if result.done then
					break
				end
				self.items[result.value] = true
			end
		else
			for ____, value in ipairs(values) do
				self.items[value] = true
			end
		end
	end
	function WeakSet.prototype.add(self, value)
		self.items[value] = true
		return self
	end
	function WeakSet.prototype.delete(self, value)
		local contains = self:has(value)
		self.items[value] = nil
		return contains
	end
	function WeakSet.prototype.has(self, value)
		return self.items[value] == true
	end
	WeakSet[Symbol.species] = WeakSet
end
