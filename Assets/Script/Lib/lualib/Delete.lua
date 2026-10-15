local function __TS__Delete(target, key)
	local descriptors = __TS__ObjectGetOwnPropertyDescriptors(target)
	local descriptor = descriptors[key]
	if descriptor then
		if not descriptor.configurable then
			error(
				__TS__New(
					TypeError,
					((("Cannot delete property " .. tostring(key)) .. " of ") .. tostring(target)) .. "."
				),
				0
			)
		end
		descriptors[key] = nil
		return true
	end
	target[key] = nil
	return true
end
