local __TS__StringReplace
do
	local sub = string.sub
	function __TS__StringReplace(source, searchValue, replaceValue)
		local startPos, endPos = string.find(source, searchValue, nil, true)
		if not startPos then
			return source
		end
		local before = sub(source, 1, startPos - 1)
		local replacement = type(replaceValue) == "string" and replaceValue or replaceValue(nil, searchValue, startPos - 1, source)
		local after = sub(source, endPos + 1)
		return (before .. replacement) .. after
	end
end
