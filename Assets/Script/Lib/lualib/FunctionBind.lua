local function __TS__FunctionBind(fn, ...)
	local boundArgs = {...}
	return function(____, ...)
		local args = {...}
		__TS__ArrayUnshift(
			args,
			__TS__Unpack(boundArgs)
		)
		return fn(__TS__Unpack(args))
	end
end
