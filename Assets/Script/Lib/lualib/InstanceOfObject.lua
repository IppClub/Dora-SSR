local function __TS__InstanceOfObject(value)
	local valueType = type(value)
	return valueType == "table" or valueType == "function"
end
