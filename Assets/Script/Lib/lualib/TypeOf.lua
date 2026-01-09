local function __TS__TypeOf(value)
	local luaType = type(value)
	if luaType == "table" then
		return "object"
	elseif luaType == "nil" then
		return "undefined"
	else
		return luaType
	end
end
