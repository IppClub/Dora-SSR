local function __TS__ObjectAssign(target, ...)
	local sources = {...}
	for i = 1, #sources do
		local source = sources[i]
		for key in pairs(source) do
			target[key] = source[key]
		end
	end
	return target
end
