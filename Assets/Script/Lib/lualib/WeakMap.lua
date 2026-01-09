local WeakMap
do
	WeakMap = __TS__Class()
	WeakMap.name = "WeakMap"
	function WeakMap.prototype.____constructor(self, entries)
		self[Symbol.toStringTag] = "WeakMap"
		self.items = {}
		setmetatable(self.items, {__mode = "k"})
		if entries == nil then
			return
		end
		local iterable = entries
		if iterable[Symbol.iterator] then
			local iterator = iterable[Symbol.iterator](iterable)
			while true do
				local result = iterator:next()
				if result.done then
					break
				end
				local value = result.value
				self.items[value[1]] = value[2]
			end
		else
			for ____, kvp in ipairs(entries) do
				self.items[kvp[1]] = kvp[2]
			end
		end
	end
	function WeakMap.prototype.delete(self, key)
		local contains = self:has(key)
		self.items[key] = nil
		return contains
	end
	function WeakMap.prototype.get(self, key)
		return self.items[key]
	end
	function WeakMap.prototype.has(self, key)
		return self.items[key] ~= nil
	end
	function WeakMap.prototype.set(self, key, value)
		self.items[key] = value
		return self
	end
	WeakMap[Symbol.species] = WeakMap
end
