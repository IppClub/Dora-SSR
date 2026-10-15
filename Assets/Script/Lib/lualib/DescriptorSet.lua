local __TS__DescriptorSet
do
	local getmetatable = _G.getmetatable
	local ____rawget = _G.rawget
	local rawset = _G.rawset
	function __TS__DescriptorSet(self, metatable, key, value)
		while metatable do
			local descriptors = ____rawget(metatable, "_descriptors")
			if descriptors then
				local descriptor = descriptors[key]
				if descriptor ~= nil then
					if descriptor.set then
						descriptor.set(self, value)
					else
						if descriptor.writable == false then
							error(
								((("Cannot assign to read only property '" .. key) .. "' of object '") .. tostring(self)) .. "'",
								0
							)
						end
						descriptor.value = value
					end
					return
				end
			end
			metatable = getmetatable(metatable)
		end
		rawset(self, key, value)
	end
end
