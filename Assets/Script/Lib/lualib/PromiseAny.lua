local function __TS__PromiseAny(iterable)
	local rejections = {}
	local pending = {}
	for ____, item in __TS__Iterator(iterable) do
		if __TS__InstanceOf(item, __TS__Promise) then
			if item.state == 1 then
				return __TS__Promise.resolve(item.value)
			elseif item.state == 2 then
				rejections[#rejections + 1] = item.rejectionReason
			else
				pending[#pending + 1] = item
			end
		else
			return __TS__Promise.resolve(item)
		end
	end
	if #pending == 0 then
		return __TS__Promise.reject("No promises to resolve with .any()")
	end
	local numResolved = 0
	return __TS__New(
		__TS__Promise,
		function(____, resolve, reject)
			for ____, promise in ipairs(pending) do
				promise["then"](
					promise,
					function(____, data)
						resolve(nil, data)
					end,
					function(____, reason)
						rejections[#rejections + 1] = reason
						numResolved = numResolved + 1
						if numResolved == #pending then
							reject(nil, {name = "AggregateError", message = "All Promises rejected", errors = rejections})
						end
					end
				)
			end
		end
	)
end
