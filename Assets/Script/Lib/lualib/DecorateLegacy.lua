local function __TS__DecorateLegacy(decorators, target, key, desc)
	local result = target
	do
		local i = #decorators
		while i >= 0 do
			local decorator = decorators[i + 1]
			if decorator ~= nil then
				local oldResult = result
				if key == nil then
					result = decorator(nil, result)
				elseif desc == true then
					local value = rawget(target, key)
					local descriptor = __TS__ObjectGetOwnPropertyDescriptor(target, key) or ({configurable = true, writable = true, value = value})
					local desc = decorator(nil, target, key, descriptor) or descriptor
					local isSimpleValue = desc.configurable == true and desc.writable == true and not desc.get and not desc.set
					if isSimpleValue then
						rawset(target, key, desc.value)
					else
						__TS__SetDescriptor(
							target,
							key,
							__TS__ObjectAssign({}, descriptor, desc)
						)
					end
				elseif desc == false then
					result = decorator(nil, target, key, desc)
				else
					result = decorator(nil, target, key)
				end
				result = result or oldResult
			end
			i = i - 1
		end
	end
	return result
end
