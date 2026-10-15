local function __TS__PromiseAllSettled(iterable)
	local results = {}
	local toResolve = {}
	local numToResolve = 0
	local i = 0
	for ____, item in __TS__Iterator(iterable) do
		if __TS__InstanceOf(item, __TS__Promise) then
			if item.state == 1 then
				results[i + 1] = {status = "fulfilled", value = item.value}
			elseif item.state == 2 then
				results[i + 1] = {status = "rejected", reason = item.rejectionReason}
			else
				numToResolve = numToResolve + 1
				toResolve[i] = item
			end
		else
			results[i + 1] = {status = "fulfilled", value = item}
		end
		i = i + 1
	end
	if numToResolve == 0 then
		return __TS__Promise.resolve(results)
	end
	return __TS__New(
		__TS__Promise,
		function(____, resolve)
			for index, promise in pairs(toResolve) do
				promise["then"](
					promise,
					function(____, data)
						results[index + 1] = {status = "fulfilled", value = data}
						numToResolve = numToResolve - 1
						if numToResolve == 0 then
							resolve(nil, results)
						end
					end,
					function(____, reason)
						results[index + 1] = {status = "rejected", reason = reason}
						numToResolve = numToResolve - 1
						if numToResolve == 0 then
							resolve(nil, results)
						end
					end
				)
			end
		end
	)
end
