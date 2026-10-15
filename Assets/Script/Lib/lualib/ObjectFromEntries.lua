local function __TS__ObjectFromEntries(entries)
	local obj = {}
	local iterable = entries
	if iterable[Symbol.iterator] then
		local iterator = iterable[Symbol.iterator](iterable)
		while true do
			local result = iterator:next()
			if result.done then
				break
			end
			local value = result.value
			obj[value[1]] = value[2]
		end
	else
		for ____, entry in ipairs(entries) do
			obj[entry[1]] = entry[2]
		end
	end
	return obj
end
