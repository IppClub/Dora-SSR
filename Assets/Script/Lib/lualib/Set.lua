local Set
do
	Set = __TS__Class()
	Set.name = "Set"
	function Set.prototype.____constructor(self, values)
		self[Symbol.toStringTag] = "Set"
		self.size = 0
		self.nextKey = {}
		self.previousKey = {}
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
				self:add(result.value)
			end
		else
			local array = values
			for ____, value in ipairs(array) do
				self:add(value)
			end
		end
	end
	function Set.prototype.add(self, value)
		local isNewValue = not self:has(value)
		if isNewValue then
			self.size = self.size + 1
		end
		if self.firstKey == nil then
			self.firstKey = value
			self.lastKey = value
		elseif isNewValue then
			self.nextKey[self.lastKey] = value
			self.previousKey[value] = self.lastKey
			self.lastKey = value
		end
		return self
	end
	function Set.prototype.clear(self)
		self.nextKey = {}
		self.previousKey = {}
		self.firstKey = nil
		self.lastKey = nil
		self.size = 0
	end
	function Set.prototype.delete(self, value)
		local contains = self:has(value)
		if contains then
			self.size = self.size - 1
			local next = self.nextKey[value]
			local previous = self.previousKey[value]
			if next ~= nil and previous ~= nil then
				self.nextKey[previous] = next
				self.previousKey[next] = previous
			elseif next ~= nil then
				self.firstKey = next
				self.previousKey[next] = nil
			elseif previous ~= nil then
				self.lastKey = previous
				self.nextKey[previous] = nil
			else
				self.firstKey = nil
				self.lastKey = nil
			end
			self.nextKey[value] = nil
			self.previousKey[value] = nil
		end
		return contains
	end
	function Set.prototype.forEach(self, callback)
		for ____, key in __TS__Iterator(self:keys()) do
			callback(nil, key, key, self)
		end
	end
	function Set.prototype.has(self, value)
		return self.nextKey[value] ~= nil or self.lastKey == value
	end
	Set.prototype[Symbol.iterator] = function(self)
		return self:values()
	end
	function Set.prototype.entries(self)
		local nextKey = self.nextKey
		local key = self.firstKey
		return {
			[Symbol.iterator] = function(self)
				return self
			end,
			next = function(self)
				local result = {done = not key, value = {key, key}}
				key = nextKey[key]
				return result
			end
		}
	end
	function Set.prototype.keys(self)
		local nextKey = self.nextKey
		local key = self.firstKey
		return {
			[Symbol.iterator] = function(self)
				return self
			end,
			next = function(self)
				local result = {done = not key, value = key}
				key = nextKey[key]
				return result
			end
		}
	end
	function Set.prototype.values(self)
		local nextKey = self.nextKey
		local key = self.firstKey
		return {
			[Symbol.iterator] = function(self)
				return self
			end,
			next = function(self)
				local result = {done = not key, value = key}
				key = nextKey[key]
				return result
			end
		}
	end
	function Set.prototype.union(self, other)
		local result = __TS__New(Set, self)
		for ____, item in __TS__Iterator(other) do
			result:add(item)
		end
		return result
	end
	function Set.prototype.intersection(self, other)
		local result = __TS__New(Set)
		for ____, item in __TS__Iterator(self) do
			if other:has(item) then
				result:add(item)
			end
		end
		return result
	end
	function Set.prototype.difference(self, other)
		local result = __TS__New(Set, self)
		for ____, item in __TS__Iterator(other) do
			result:delete(item)
		end
		return result
	end
	function Set.prototype.symmetricDifference(self, other)
		local result = __TS__New(Set, self)
		for ____, item in __TS__Iterator(other) do
			if self:has(item) then
				result:delete(item)
			else
				result:add(item)
			end
		end
		return result
	end
	function Set.prototype.isSubsetOf(self, other)
		for ____, item in __TS__Iterator(self) do
			if not other:has(item) then
				return false
			end
		end
		return true
	end
	function Set.prototype.isSupersetOf(self, other)
		for ____, item in __TS__Iterator(other) do
			if not self:has(item) then
				return false
			end
		end
		return true
	end
	function Set.prototype.isDisjointFrom(self, other)
		for ____, item in __TS__Iterator(self) do
			if other:has(item) then
				return false
			end
		end
		return true
	end
	Set[Symbol.species] = Set
end
