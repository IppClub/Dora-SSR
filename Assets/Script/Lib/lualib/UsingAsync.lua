local function __TS__UsingAsync(self, cb, ...)
	local args = {...}
	return __TS__AsyncAwaiter(function(____awaiter_resolve)
		local thrownError
		local ok, result = xpcall(
			function() return cb(
				nil,
				__TS__Unpack(args)
			) end,
			function(err)
				thrownError = err
				return thrownError
			end
		)
		local argArray = {__TS__Unpack(args)}
		do
			local i = #argArray - 1
			while i >= 0 do
				if argArray[i + 1][Symbol.dispose] ~= nil then
					local ____self_0 = argArray[i + 1]
					____self_0[Symbol.dispose](____self_0)
				end
				if argArray[i + 1][Symbol.asyncDispose] ~= nil then
					local ____self_1 = argArray[i + 1]
					__TS__Await(____self_1[Symbol.asyncDispose](____self_1))
				end
				i = i - 1
			end
		end
		if not ok then
			error(thrownError, 0)
		end
		return ____awaiter_resolve(nil, result)
	end)
end
