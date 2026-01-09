local function __TS__MathSign(val)
	if __TS__NumberIsNaN(val) or val == 0 then
		return val
	end
	if val < 0 then
		return -1
	end
	return 1
end
