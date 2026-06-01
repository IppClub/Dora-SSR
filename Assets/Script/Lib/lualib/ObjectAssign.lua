local function __TS__ObjectAssign(target, ...)
	local sources = {...}
	for i = 1, #sources do
		local source = sources[i]
		if type(source) == "table" then
			for key in pairs(source) do
				target[key] = source[key]
			end
		end
	end
	return target
end
