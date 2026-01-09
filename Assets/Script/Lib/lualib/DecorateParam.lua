local function __TS__DecorateParam(paramIndex, decorator)
	return function(____, target, key) return decorator(nil, target, key, paramIndex) end
end
