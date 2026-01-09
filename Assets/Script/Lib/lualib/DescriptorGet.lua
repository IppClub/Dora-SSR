local __TS__DescriptorGet
do
	local getmetatable = _G.getmetatable
	local ____rawget = _G.rawget
	function __TS__DescriptorGet(self, metatable, key)
		while metatable do
			local rawResult = ____rawget(metatable, key)
			if rawResult ~= nil then
				return rawResult
			end
			local descriptors = ____rawget(metatable, "_descriptors")
			if descriptors then
				local descriptor = descriptors[key]
				if descriptor ~= nil then
					if descriptor.get then
						return descriptor.get(self)
					end
					return descriptor.value
				end
			end
			metatable = getmetatable(metatable)
		end
	end
end
