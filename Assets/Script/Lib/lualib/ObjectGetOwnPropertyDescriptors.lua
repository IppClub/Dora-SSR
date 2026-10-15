local function __TS__ObjectGetOwnPropertyDescriptors(object)
	local metatable = getmetatable(object)
	if not metatable then
		return {}
	end
	return rawget(metatable, "_descriptors") or ({})
end
