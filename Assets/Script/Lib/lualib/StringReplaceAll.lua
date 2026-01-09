local __TS__StringReplaceAll
do
	local sub = string.sub
	local find = string.find
	function __TS__StringReplaceAll(source, searchValue, replaceValue)
		if type(replaceValue) == "string" then
			local concat = table.concat(
				__TS__StringSplit(source, searchValue),
				replaceValue
			)
			if #searchValue == 0 then
				return (replaceValue .. concat) .. replaceValue
			end
			return concat
		end
		local parts = {}
		local partsIndex = 1
		if #searchValue == 0 then
			parts[1] = replaceValue(nil, "", 0, source)
			partsIndex = 2
			for i = 1, #source do
				parts[partsIndex] = sub(source, i, i)
				parts[partsIndex + 1] = replaceValue(nil, "", i, source)
				partsIndex = partsIndex + 2
			end
		else
			local currentPos = 1
			while true do
				local startPos, endPos = find(source, searchValue, currentPos, true)
				if not startPos then
					break
				end
				parts[partsIndex] = sub(source, currentPos, startPos - 1)
				parts[partsIndex + 1] = replaceValue(nil, searchValue, startPos - 1, source)
				partsIndex = partsIndex + 2
				currentPos = endPos + 1
			end
			parts[partsIndex] = sub(source, currentPos)
		end
		return table.concat(parts)
	end
end
