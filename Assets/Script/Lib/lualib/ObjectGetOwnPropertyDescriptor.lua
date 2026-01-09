local function __TS__ObjectGetOwnPropertyDescriptor(object, key)
	local metatable = getmetatable(object)
	if not metatable then
		return
	end
	if not rawget(metatable, "_descriptors") then
		return
	end
	return rawget(metatable, "_descriptors")[key]
end
