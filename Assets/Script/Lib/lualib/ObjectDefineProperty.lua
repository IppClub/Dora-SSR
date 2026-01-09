local function __TS__ObjectDefineProperty(target, key, desc)
	local luaKey = type(key) == "number" and key + 1 or key
	local value = rawget(target, luaKey)
	local hasGetterOrSetter = desc.get ~= nil or desc.set ~= nil
	local descriptor
	if hasGetterOrSetter then
		if value ~= nil then
			error(
				"Cannot redefine property: " .. tostring(key),
				0
			)
		end
		descriptor = desc
	else
		local valueExists = value ~= nil
		local ____desc_set_4 = desc.set
		local ____desc_get_5 = desc.get
		local ____desc_configurable_0 = desc.configurable
		if ____desc_configurable_0 == nil then
			____desc_configurable_0 = valueExists
		end
		local ____desc_enumerable_1 = desc.enumerable
		if ____desc_enumerable_1 == nil then
			____desc_enumerable_1 = valueExists
		end
		local ____desc_writable_2 = desc.writable
		if ____desc_writable_2 == nil then
			____desc_writable_2 = valueExists
		end
		local ____temp_3
		if desc.value ~= nil then
			____temp_3 = desc.value
		else
			____temp_3 = value
		end
		descriptor = {
			set = ____desc_set_4,
			get = ____desc_get_5,
			configurable = ____desc_configurable_0,
			enumerable = ____desc_enumerable_1,
			writable = ____desc_writable_2,
			value = ____temp_3
		}
	end
	__TS__SetDescriptor(target, luaKey, descriptor)
	return target
end
