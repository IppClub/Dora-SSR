local function __TS__NumberIsFinite(value)
	return type(value) == "number" and value == value and value ~= math.huge and value ~= -math.huge
end
