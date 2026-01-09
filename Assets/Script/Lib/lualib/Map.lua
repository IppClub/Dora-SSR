local Map
do
	Map = __TS__Class()
	Map.name = "Map"
	function Map.prototype.____constructor(self, entries)
		self[Symbol.toStringTag] = "Map"
		self.items = {}
		self.size = 0
		self.nextKey = {}
		self.previousKey = {}
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
				self:set(value[1], value[2])
			end
		else
			local array = entries
			for ____, kvp in ipairs(array) do
				self:set(kvp[1], kvp[2])
			end
		end
	end
	function Map.prototype.clear(self)
		self.items = {}
		self.nextKey = {}
		self.previousKey = {}
		self.firstKey = nil
		self.lastKey = nil
		self.size = 0
	end
	function Map.prototype.delete(self, key)
		local contains = self:has(key)
		if contains then
			self.size = self.size - 1
			local next = self.nextKey[key]
			local previous = self.previousKey[key]
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
			self.nextKey[key] = nil
			self.previousKey[key] = nil
		end
		self.items[key] = nil
		return contains
	end
	function Map.prototype.forEach(self, callback)
		for ____, key in __TS__Iterator(self:keys()) do
			callback(nil, self.items[key], key, self)
		end
	end
	function Map.prototype.get(self, key)
		return self.items[key]
	end
	function Map.prototype.has(self, key)
		return self.nextKey[key] ~= nil or self.lastKey == key
	end
	function Map.prototype.set(self, key, value)
		local isNewValue = not self:has(key)
		if isNewValue then
			self.size = self.size + 1
		end
		self.items[key] = value
		if self.firstKey == nil then
			self.firstKey = key
			self.lastKey = key
		elseif isNewValue then
			self.nextKey[self.lastKey] = key
			self.previousKey[key] = self.lastKey
			self.lastKey = key
		end
		return self
	end
	Map.prototype[Symbol.iterator] = function(self)
		return self:entries()
	end
	function Map.prototype.entries(self)
		local items = self.items
		local nextKey = self.nextKey
		local key = self.firstKey
		return {
			[Symbol.iterator] = function(self)
				return self
			end,
			next = function(self)
				local result = {done = not key, value = {key, items[key]}}
				key = nextKey[key]
				return result
			end
		}
	end
	function Map.prototype.keys(self)
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
	function Map.prototype.values(self)
		local items = self.items
		local nextKey = self.nextKey
		local key = self.firstKey
		return {
			[Symbol.iterator] = function(self)
				return self
			end,
			next = function(self)
				local result = {done = not key, value = items[key]}
				key = nextKey[key]
				return result
			end
		}
	end
	Map[Symbol.species] = Map
end
