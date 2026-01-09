local function __TS__ArrayIsArray(value)
	return type(value) == "table" and (value[1] ~= nil or next(value) == nil)
end
