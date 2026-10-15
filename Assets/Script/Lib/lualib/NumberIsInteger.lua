local function __TS__NumberIsInteger(value)
	return __TS__NumberIsFinite(value) and math.floor(value) == value
end
