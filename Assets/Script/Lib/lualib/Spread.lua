local function __TS__Spread(iterable)
	local arr = {}
	if type(iterable) == "string" then
		for i = 0, #iterable - 1 do
			arr[i + 1] = __TS__StringAccess(iterable, i)
		end
	else
		local len = 0
		for ____, item in __TS__Iterator(iterable) do
			len = len + 1
			arr[len] = item
		end
	end
	return __TS__Unpack(arr)
end
