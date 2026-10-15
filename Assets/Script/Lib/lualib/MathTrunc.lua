local function __TS__MathTrunc(val)
	if not __TS__NumberIsFinite(val) or val == 0 then
		return val
	end
	return val > 0 and math.floor(val) or math.ceil(val)
end
