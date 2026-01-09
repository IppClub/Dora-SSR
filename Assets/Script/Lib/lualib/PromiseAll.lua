local function __TS__PromiseAll(iterable)
	local results = {}
	local toResolve = {}
	local numToResolve = 0
	local i = 0
	for ____, item in __TS__Iterator(iterable) do
		if __TS__InstanceOf(item, __TS__Promise) then
			if item.state == 1 then
				results[i + 1] = item.value
			elseif item.state == 2 then
				return __TS__Promise.reject(item.rejectionReason)
			else
				numToResolve = numToResolve + 1
				toResolve[i] = item
			end
		else
			results[i + 1] = item
		end
		i = i + 1
	end
	if numToResolve == 0 then
		return __TS__Promise.resolve(results)
	end
	return __TS__New(
		__TS__Promise,
		function(____, resolve, reject)
			for index, promise in pairs(toResolve) do
				promise["then"](
					promise,
					function(____, data)
						results[index + 1] = data
						numToResolve = numToResolve - 1
						if numToResolve == 0 then
							resolve(nil, results)
						end
					end,
					function(____, reason)
						reject(nil, reason)
					end
				)
			end
		end
	)
end
