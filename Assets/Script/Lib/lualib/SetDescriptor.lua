local __TS__SetDescriptor
do
	local getmetatable = _G.getmetatable
	local function descriptorIndex(self, key)
		return __TS__DescriptorGet(
			self,
			getmetatable(self),
			key
		)
	end
	local function descriptorNewIndex(self, key, value)
		return __TS__DescriptorSet(
			self,
			getmetatable(self),
			key,
			value
		)
	end
	function __TS__SetDescriptor(target, key, desc, isPrototype)
		if isPrototype == nil then
			isPrototype = false
		end
		local ____isPrototype_0
		if isPrototype then
			____isPrototype_0 = target
		else
			____isPrototype_0 = getmetatable(target)
		end
		local metatable = ____isPrototype_0
		if not metatable then
			metatable = {}
			setmetatable(target, metatable)
		end
		local value = rawget(target, key)
		if value ~= nil then
			rawset(target, key, nil)
		end
		if not rawget(metatable, "_descriptors") then
			metatable._descriptors = {}
		end
		metatable._descriptors[key] = __TS__CloneDescriptor(desc)
		metatable.__index = descriptorIndex
		metatable.__newindex = descriptorNewIndex
	end
end
