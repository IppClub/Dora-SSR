local function __TS__Using(self, cb, ...)
	local args = {...}
	local thrownError
	local ok, result = xpcall(
		function() return cb(__TS__Unpack(args)) end,
		function(err)
			thrownError = err
			return thrownError
		end
	)
	local argArray = {__TS__Unpack(args)}
	do
		local i = #argArray - 1
		while i >= 0 do
			local ____self_0 = argArray[i + 1]
			____self_0[Symbol.dispose](____self_0)
			i = i - 1
		end
	end
	if not ok then
		error(thrownError, 0)
	end
	return result
end
